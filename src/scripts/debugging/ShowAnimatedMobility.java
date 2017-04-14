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
  }


  class AnimationPanel extends JPanel {
    double maxX = -1;
    double maxY = -1;

    AnimationPanel() {
      // set a preferred size for the custom panel.
      setPreferredSize(new Dimension(420,420));
      initAnimationIterator();

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
        g2.draw(new Rectangle2D.Double(81/maxX*dimension.getWidth(), 81/maxY*dimension.getHeight(), 88.0/maxX*dimension.getWidth(), 88.0/maxY*dimension.getHeight()));
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
