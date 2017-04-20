import java.util.*;
import java.io.*;


import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import javax.swing.border.*;
import java.awt.geom.*;



public class ShowAnimatedMobility {

  private ArrayList<Node> nodes = new ArrayList<>();

  private static class Node {
    NodeType type;
    ArrayList<Point> positions;

    public enum NodeType {
      SPARSE, DENSE
    };

    public Node(NodeType type) {
      this.type = type;
      positions = new ArrayList<>();
    }
  }

  private static class Point {
    double x;
    double y;
    public Point(double x, double y) {
      this.x = x;
      this.y = y;
    }

    public double distance(Point p) {
      return Math.sqrt((p.x - x)*(p.x - x) + (p.y-y)*(p.y-y));
    }
  }

  private Rectangle2D.Double computeBorder(ArrayList<Node> nodes) {
    double x0 = 10000000;
    double y0 = 10000000;
    double x1 = -10000000;
    double y1 = -10000000;
    for (Node n: nodes) {
      if (n.type == Node.NodeType.DENSE) {
        if (n.positions.get(0).x < x0) x0 = n.positions.get(0).x;
        if (n.positions.get(0).x > x1) x1 = n.positions.get(0).x;
        if (n.positions.get(0).y < y0) y0 = n.positions.get(0).y;
        if (n.positions.get(0).y > y1) y1 = n.positions.get(0).y;
      }
    }
    return new Rectangle2D.Double(x0, y0, x1-x0, y1-y0);
  }


  private ArrayList<ArrayList<Node>> kmeans(int k) {
    ArrayList<Point> centroids = new ArrayList<>();
    int[] map2cluster = new int[nodes.size()];
    Arrays.fill(map2cluster, -1);

    // initial centroids
    double maxX = -1;
    double maxY = -1;
    for (Node n: nodes) {
      Point p = n.positions.get(0);
      if (p.x > maxX) maxX = p.x;
      if (p.y > maxY) maxY = p.y;
    }
    for (int i = 0 ; i < 4; i++) {
      Point p = new Point(Math.random()*maxX, Math.random()*maxY);
      centroids.add(p);
    }

    // main loop in k-means
    do {
      boolean someChange = false;
      for (int i = 0 ; i < nodes.size() ; i++) {
        if (nodes.get(i).type == Node.NodeType.DENSE) {
          Point pn = nodes.get(i).positions.get(0);
          int i_min = -1;
          double d_min = 1000000000;
          for (int j = 0 ; j < centroids.size(); j++) {
            double dist = pn.distance(centroids.get(j));
            if (dist < d_min) {
              i_min = j;
              d_min = dist;
            }
          }
          if (map2cluster[i] != i_min) {
            map2cluster[i] = i_min;
            someChange = true;
          }
        }
      }
      if (!someChange) break;
      // recompute centroids
      int[] count = new int[centroids.size()];
      for (Point p: centroids) {
        p.x = 0.0; p.y = 0.0;
      }
      for (int i = 0 ; i < nodes.size(); i++) {
        int idx = map2cluster[i];
        if (idx != -1) {
          centroids.get(idx).x += nodes.get(i).positions.get(0).x;
          centroids.get(idx).y += nodes.get(i).positions.get(0).y;
          count[idx] ++;
        }
      }
      for (int i = 0 ; i < centroids.size(); i++) {
        Point p = centroids.get(i);
        p.x /= count[i]; p.y /= count[i];
      }
    } while (true);

    ArrayList<ArrayList<Node>> result = new ArrayList<>();
    for (Point p : centroids) result.add(new ArrayList<>());
    for (int i = 0 ; i < nodes.size(); i++) {
      int idx = map2cluster[i];
      if (idx != -1) {
        result.get(idx).add(nodes.get(i));
      }
    }

    return result;
  }


  class AnimationPanel extends JPanel {
    double maxX = -1;
    double maxY = -1;

    ArrayList<Rectangle2D.Double> borders;

    AnimationPanel() {
      // set a preferred size for the custom panel.
      setPreferredSize(new Dimension(420,420));
      initAnimationIterator();

      borders = new ArrayList<>();
      ArrayList<ArrayList<Node>> rrr = kmeans(4);
      for (ArrayList<Node> cluster : rrr) {
        borders.add(computeBorder(cluster));
      }

      int delay = 10; //milliseconds
      ActionListener taskPerformer = new ActionListener() {
          public void actionPerformed(ActionEvent evt) {
              AnimationPanel.this.revalidate();
              AnimationPanel.this.repaint();
          }
      };
      new javax.swing.Timer(delay, taskPerformer).start();
    }

    @Override
    public void paintComponent(Graphics g) {
      super.paintComponent(g);
      if (g instanceof Graphics2D) {
        Graphics2D g2 = (Graphics2D)g;


        Dimension dimension = getSize();

        for (Node n: nodes) {
          Point p = getPosition(n);
          if (p.x > maxX) maxX = p.x;
          if (p.y > maxY) maxY = p.y;
        }

        int idx = 0;
        for (Node n: nodes) {
          Point p = getPosition(n);
          if (n.type == Node.NodeType.SPARSE) {
            g2.setColor(Color.RED);
          }
          else {
            g2.setColor(Color.BLUE);
          }
          g2.fill(new Ellipse2D.Double(p.x/maxX*dimension.getWidth(), p.y/maxY*dimension.getHeight(), 10, 10));
          if (idx % 25 == 0) {
            double ttX = 40.0/maxX*dimension.getWidth();
            double ttY = 40.0/maxY*dimension.getHeight();
            g2.draw(new Ellipse2D.Double(p.x/maxX*dimension.getWidth() + 5 - ttX/2, p.y/maxY*dimension.getHeight() + 5 - ttY/2, ttX, ttY));

          }
          idx ++;
        }

        g2.setColor(Color.BLACK);
        for (Rectangle2D.Double r: borders) {
          g2.draw(new Rectangle2D.Double(r.getX()/maxX*dimension.getWidth(), r.getY()/maxY*dimension.getHeight(), r.getWidth()/maxX*dimension.getWidth(), r.getHeight()/maxY*dimension.getHeight()));
        }
      }
      moveAnimationIterator();
    }
  }


  private int currentAnimationPointer;

  private void initAnimationIterator() {
    this.currentAnimationPointer = 0;
  }

  private Point getPosition(Node n) {
    return n.positions.get(currentAnimationPointer);
  }

  private boolean moveAnimationIterator() {
    currentAnimationPointer ++;
    if (currentAnimationPointer == nodes.get(0).positions.size())
      currentAnimationPointer = 0;
    return true;
  }


  private void readNodes(String densityFile) {
    try (BufferedReader br = new BufferedReader(new FileReader(densityFile))) {
      String line;
      while ((line = br.readLine()) != null) {
         String[] tmp = line.split(",");
         int density = Integer.parseInt(tmp[1].trim());
         nodes.add(new Node((density < 20)? Node.NodeType.SPARSE: Node.NodeType.DENSE));
      }
    }
    catch (IOException ex) {
      System.err.println("Couldn't read density file " + densityFile);
    }
  }

  private void readMobilityTraces(String mobilityFile) {
    try (BufferedReader br = new BufferedReader(new FileReader(mobilityFile))) {
      String line;
      // discard first to messages
      br.readLine();
      br.readLine();
      int idx = 0;
      while ((line = br.readLine()) != null) {
         String[] tmp = line.split(" ");
         double x = Double.parseDouble(tmp[0].trim());
         double y = Double.parseDouble(tmp[1].trim());
         nodes.get((idx++) % nodes.size()).positions.add(new Point(x, y));
      }
    }
    catch (IOException ex) {
      System.err.println("Couldn't read mobility file " + mobilityFile);
    }
  }


  private void initGUI() {
    JFrame frame = new JFrame("Topology animation");
    JPanel animationPanel = new AnimationPanel();
    frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
    frame.setContentPane(animationPanel);
    frame.pack();
    frame.show();
  }


  private void run(String[] args) {
    System.out.println("Reading density file");
    readNodes(args[0]);
    System.out.println("Reading mobility file");
    readMobilityTraces(args[1]);
    System.out.println("Start User Interface");
    initGUI();
  }

  public static void main(String[] args) {
    new ShowAnimatedMobility().run(args);
  }
}
