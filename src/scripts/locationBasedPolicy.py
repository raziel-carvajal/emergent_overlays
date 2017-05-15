import random as rm
import math
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

origin = (0,0)

def getPointsInCircle(n):
  i, points = 0, []
  while i < n:
    x, y = rm.uniform(-1, 1), rm.uniform(-1, 1)
    if math.sqrt(x*x + y*y) <= 1:
      p = (x, y, 0)
      points.append(p)
      i = i + 1
  return points

def getRadsFromQuadrant(p):
  print("point: ("+str(p[0])+", "+str(p[1])+")")
  h = math.sqrt( p[0]*p[0] + p[1]*p[1] )
  theta = math.asin( abs(p[1] - origin[0]) / h )
  r = (p[0] - origin[0], p[1] - origin[1])
  # radians of quadrant I
  if r[0] >= 0 and r[1] >= 0:
    print("quad: I")
    return theta
  # radians of quadrant II
  if r[0] < 0 and r[1] >= 0:
    print("quad: II")
    return math.pi - theta
  # radians of quadrant III
  if r[0] <= 0 and r[1] < 0:
    print("quad: III")
    return math.pi + theta
  # radians of quadrant IV
  if r[0] > 0 and r[1] < 0:
    print("quad: IV")
    return 2*math.pi - theta

def getQuadrantNo(p):
  r = (p[0] - origin[0], p[1] - origin[1])
  # radians of quadrant I
  if r[0] >= 0 and r[1] >= 0:
    return 0
  # radians of quadrant II
  if r[0] < 0 and r[1] >= 0:
    return 1
  # radians of quadrant III
  if r[0] <= 0 and r[1] < 0:
    return 2
  # radians of quadrant IV
  if r[0] > 0 and r[1] < 0:
    return 3

if __name__ == '__main__':
  circle = plt.Circle((0,0), 1, fill=False)
  fig = plt.gcf()
  ax  = fig.gca()
  ax.set_xlim((-1, 1))
  ax.set_ylim((-1, 1))
  points, alphas, i = getPointsInCircle(20), [], 0
  while i < len(points):
    p = points[i]
    ax.plot((p[0]), (p[1]), 'o', color='black')
    alphas.append( getRadsFromQuadrant( (p[0], p[1]) ) )
    i = i + 1
  alphas = sorted(alphas)
  ax.add_artist(circle)
  i , betas = 0, []
  while i < len(alphas) - 1:
    t = (alphas[i+1] - alphas[i], i)
    betas.append( t )
    i = i + 1
  t = (2*math.pi - alphas[len(alphas) - 1] + alphas[0], i)
  betas.append( t )
  betas = sorted(betas, key=lambda item: item[0], reverse=True)
  i = betas[0][1]
  wedge = mpatches.Wedge((0,0), 1, math.degrees(alphas[i]), math.degrees(alphas[i] + betas[0][0]), ec="none")
  ax.add_artist(wedge)
  fig.savefig("test.png")
