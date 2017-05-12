"""This module builds a set of topologies with given densities."""

# =============================================================================
#
#          FILE: buildTopology.py
#
#         USAGE: python buildTopology.py nodes transmissionRange layoutSize
#                topologyFile
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (RCG), raziel.carvajal@unine.ch
#  ORGANIZATION:
#       CREATED: 06/22/16 19:37
#      REVISION:  ---
# =============================================================================

import random
import math
import networkx as nx
import argparse
import logging
import genmobility
import matplotlib.pyplot as plt

from omnetFiles import createNedFile, create_density_file
import kdTree


# network density
density = {'sparse': 2, 'medium': 5, 'dense': 10}

logger = logging.getLogger("mobility-generator")


def get_arguments():
    parser = argparse.ArgumentParser(description='Generate a topology using random geometric graphs.')
    parser.add_argument('--tx', dest='tx', type=int, default=10,
                        help='Transmission Range (default: 10)')
    parser.add_argument('--min_d', dest='min_density', type=int, default=5,
                        help='Minimum density (default: 5)')
    parser.add_argument('--max_d', dest='max_density', type=int, default=65,
                        help='Maximum density (default: 65)')
    parser.add_argument('--idx', dest='last_idx', type=int, default=0,
                        help='last id number used to identify topologies (default: 0)')
    parser.add_argument('--nodes', dest='nr_nodes', type=int, default=200,
                        help='Number of nodes (default: 200)')
    parser.add_argument("--mobility", dest="mobility", action='store_true',
                        help="Generate mobility files")

    parser.add_argument("--distributed", dest="distributed", action='store_true',
                        help="Should generate broadcasts from many nodes.")

    parser.add_argument("--sessions", dest="nr_sessions", type=int, default=300,
                        help="How many broadcast sessions. Only make sense if distributed source ( default: 300).")

    parser.add_argument("--non-uniform", dest="non_uniform", action='store_true',
                        help="Should generate a topology with non uniform density.")
    parser.add_argument("--handcrafted", dest="handcrafted", action='store_true',
                        help="Should generate a handcrafted topology.")

    parser.add_argument("--save-fig", dest="savedfigure", type=str,
                        help="Save an image of the topology at.")

    args = parser.parse_args()
    return args


def build_graph(pos, tx):
    g = nx.Graph()
    for i, v in enumerate(pos):
        n = g.add_node(i)

    for i, v in enumerate(pos):
        x0 = v[0]
        y0 = v[1]
        c = 0
        for j in range(i+1, len(pos)):
            v2 = pos[j]
            x1 = v2[0]
            y1 = v2[1]
            d = (x1-x0)**2 + (y1-y0)**2
            if d < tx*tx:
                g.add_edge(i, j)
                c = c + 1
    return g


def find_closest(pos, components, node_idx, component_idx):
    x0 = pos[node_idx][0]
    y0 = pos[node_idx][1]
    dm = 100000000
    idx_min = -1
    for i, c in enumerate(components):
        if i != component_idx:
            indexes = c[1]
            for i in indexes:
                x1 = pos[i][0]
                y1 = pos[i][1]
                d = math.sqrt((x1 - x0)**2 + (y1 - y0)**2)
                if d < dm:
                    dm = d
                    idx_min = i
    return (dm, idx_min, node_idx)


def fix_network_connectivity(initial_g, pos, tx, threshold=80.0):
    g = initial_g
    x = [(len(c), c) for c in nx.connected_components(g)]
    maximum = max(c[0] for c in x)
    if maximum < len(pos)*threshold/100:
        return False
    while len(x) > 1:
        x.sort(lambda a, b: -1 if a[0] < b[0] else 1)
        sizes = [c[0] for c in x]
        # print len(x), " components with sizes: ", sizes
        idx_c = 0
        c = x[0]
        indices = c[1]
        ttt = [find_closest(pos, x, idx, idx_c) for idx in indices]
        ttt.sort(lambda a, b: -1 if a[0] < b[0] else 1)
        pair = ttt[0]
        # print "\t\tminimum distance : ", pair[0] - tx, ", to node:", pair[1]
        toward = pair[1]
        x0 = pos[pair[2]][0]
        y0 = pos[pair[2]][1]
        x1 = pos[toward][0]
        y1 = pos[toward][1]
        d = pair[0] - tx + 1
        px = (x1 - x0)/d
        py = (y1 - y0)/d
        # move all nodes in this component
        for idx in c[1]:
            pos[idx][0] += px
            pos[idx][1] += py
        g = build_graph(pos, tx)
        x = [(len(c), c) for c in nx.connected_components(g)]
    return True


def guarentee_connectivity(pos, tx):
    g = build_graph(pos, tx)
    b = nx.is_connected(g)
    while b is False:
        b = fix_network_connectivity(g, pos, tx)
        g = build_graph(pos, tx)
        b = nx.is_connected(g)
    return b


def is_valid_network(pos, tx, density, allowed_error):
    g = build_graph(pos, tx)
    degrees = map(lambda (k, v): v, nx.degree(g).iteritems())
    sum_degree = sum(degrees)
    avg_degree = sum_degree/float(nx.number_of_nodes(g))
    expected = density-density*allowed_error/100.0
    cond2 = abs(avg_degree - density) <= density*allowed_error/100.0
    cond1 = nx.is_connected(g)
    if cond1 and cond2:
        min_degree = min(degrees)
        max_degree = max(degrees)
        u = set(degrees)
        h = {d: len(filter(lambda x: x == d,  degrees)) for d in u}
        print avg_degree, max_degree, min_degree, expected, "Nr Nodes", nx.number_of_nodes(g), "Nr Edges", nx.number_of_edges(g), density, cond1, cond2
        print h
    if cond2 and not cond1:
        b = fix_network_connectivity(g, pos, tx)
        if b:
            g = build_graph(pos, tx)
            cond1 = nx.is_connected(g)
    return cond1 and cond2


def fillSurfaceWithFixedRadio(tx, tilesWidth, tilesHeight, density):
    r = float(tx)/(tilesWidth*2*tx)
    n = int(math.ceil(float(density)/(math.pi*r*r)))
    print n, density, r
    block_width = 2*tx
    w = tilesWidth * block_width
    h = tilesHeight * block_width
    return fillSurfaceBase(r, n, density, w, h), w, h


def compute_map_size(tx, n, density):
    r = math.sqrt(density/(n*math.pi))
    h = w = math.floor(tx/r)
    return w, h


def fillSurfaceWithFixedNumberOfNodes(tx, n, density):
    # n*pi*r^2 = d
    r = math.sqrt(density/(n*math.pi))
    w, h = compute_map_size(tx, n, density)
    return fillSurfaceBase(r, n, density, w, h), w, h


def fillSurfaceWithFixedRadioAndSize(tx, x, y, w, h, density):
    # n*pi*r^2 = d
    n = int(density * w * h / (math.pi*(tx**2)))
    r = tx/min(w, h)
    positions = fillSurfaceBase(r, n, density, w, h)
    for p in positions:
        p[0] += x
        p[1] += y
    return positions, n


def fillSurfaceBase(r, n, density, w, h):
    # assert w == h
    # print r, n, density, w
    result = []
    G = nx.Graph()
    G.add_nodes_from(range(1, n+1))
    pos = nx.random_layout(G)
    for l in pos:
        pos[l][0] = w*pos[l][0]
        pos[l][1] = h*pos[l][1]
        result.append(pos[l])
    return result


def get_callback_single_source_code(idx_source):
    def tmp(i, p):
        return "isCenter=true;" if (i == idx_source) else ""

    return tmp


def get_callback_multiple_source_code(nr_nodes, nr_max_msgs, idx_source):
    d = {i: [] for i in range(0, nr_nodes)}
    for i in range(1, nr_max_msgs+1):
        idx = random.randint(0, nr_nodes - 1)
        d[idx].append(i)

    f2 = get_callback_single_source_code(idx_source)

    def tmp(i, p):
        if len(d[i]) == 0:
            return f2(i, p)
        return str("id_messages_to_send=\"" + reduce(lambda s, v: s+" "+str(v), d[i], "") + "\";" + f2(i, p))

    return tmp


def get_still_connected_callback(tx, idx_source):
    def l(p):
        # G = build_graph(p, tx)
        # b = nx.is_connected(G)
        # if not b:
        #     x = [len(c) for c in nx.connected_components(G) if idx_source in c]
        #     logger.info("Node {0} is in a component with {1} out of {2} members".format(idx_source, x[0], len(p)))
        return True
        # return b
    return l


def draw(pos, tx, filename):
    g = build_graph(pos, tx)
    plt.figure()
    plt.axis('off')
    nx.draw_networkx(g, pos, font_size=7, node_size=10)
    plt.savefig(filename)

    pass


def create_nedfile(node_positions, w, h, density, args):
    print "Selecting source of broadcasting"
    idx_source = random.randint(0, len(node_positions) - 1)

    print "Writing NED file"
    fn_create_sources = get_callback_single_source_code(idx_source)
    if (args.distributed):
        fn_create_sources = get_callback_multiple_source_code(args.nr_nodes, args.nr_sessions, idx_source)
    createNedFile(density, node_positions, 0, int(w), int(w), args.tx, fn_create_sources)
    return idx_source


def build_uniform_topologies(args, densities):
    trRan = args.tx
    nr_nodes = args.nr_nodes
    mobility = args.mobility
    nr_sessions = args.nr_sessions

    threshold = 10
    for d in densities:

        print "Building topology with density %d and transmission range %d" % (d, trRan)
        topology, w, h = fillSurfaceWithFixedNumberOfNodes(trRan, nr_nodes, d)
        while not is_valid_network(topology, trRan, d, threshold):
            topology, w, h = fillSurfaceWithFixedNumberOfNodes(trRan, nr_nodes, d)

        idx_source = create_nedfile(topology, int(w), int(w), d, args)

        if args.savedfigure:
            draw(topology, trRan, args.savedfigure)

        if mobility:
            print "Generating mobility"
            filename = "n_{0}_d_{1}_tr_{2}_a_{3}x{4}_idx_{5}.mobility".format(nr_nodes, d, trRan, int(w), int(h), 0)
            while True:
                b = genmobility.generateMobility(sps=10, nr_nodes=nr_nodes,
                                                 map_x=int(w), map_y=int(h),
                                                 sim_time=200, positions=topology,
                                                 outputFile=filename,
                                                 test=get_still_connected_callback(trRan, idx_source))
                if b:
                    break
    pass


def find_top_density(densities, node, A, trRan, n, d0):
    A1 = node.w*node.h
    A2 = A - A1
    final_idx = -1 if A2 > 0 else 0
    for idx, D in enumerate(densities):
        n1 = int(D*A1/(math.pi*(trRan**2)))
        if n1 <= n and A2 > 0:
            n2 = n - n1
            # print "que es esto?", D, n1, n2, int((math.pi*(trRan**2))/A2*n2)
            if int((math.pi*(trRan**2))/A2*n2) >= d0:
                final_idx = idx
            else:
                break
    return final_idx


def build_handcrafted_topology(args, densities, nr_points_of_interests=1):
    trRan = args.tx
    mobility = args.mobility
    nr_sessions = args.nr_sessions

    d0 = densities[0]
    d1 = densities[1]
    w0, h0 = compute_map_size(trRan, int(args.nr_nodes/2), d0)
    print (w0, h0)

    positions = []
    generated_densities = []
    # nodes with first density
    p1, n1 = fillSurfaceWithFixedRadioAndSize(trRan, 0, 0, w0, h0, d0)
    positions.extend(p1)

    w1, h1 = compute_map_size(trRan, int(args.nr_nodes/2/nr_points_of_interests), d1)

    # nodes with second density
    count_per_row = int(math.sqrt(nr_points_of_interests))
    points_of_interest = []
    for i in range(0, nr_points_of_interests):
        idx_Col = i % count_per_row
        idx_Row = i / count_per_row
        x1 = int(w0/count_per_row)*idx_Col + int(w0/count_per_row/2 - w1/2)
        y1 = int(h0/count_per_row)*idx_Row + int(h0/count_per_row/2 - h1/2)
        print (x1, y1, x1 + w1, y1 + h1)
        points_of_interest.append((x1, y1, w1, h1))
        p2, n1 = fillSurfaceWithFixedRadioAndSize(trRan, x1, y1, w1, h1, d1)
        positions.extend(p2)

    def inInner(ppp, xx, yy, ww, hh):
        return ppp[0] >= xx and ppp[0] <= (ww+xx) and ppp[1] >= yy and ppp[1] <= (hh+yy)

    def inPointOfInterest(ppp):
        return any(map(lambda (e): inInner(ppp, e[0], e[1], e[2], e[3]), points_of_interest))

    print points_of_interest
    generated_densities.extend([(d1 if inPointOfInterest(point) else d0) for point in positions])

    mobility_map = [ (generated_densities[ii] == d0) for ii in range(0, len(generated_densities))]

    print "Fixing connectivity"
    connected = guarentee_connectivity(positions, trRan)

    idx_source = create_nedfile(positions, int(w0), int(h0), 0, args)
    create_density_file(generated_densities, int(w0), int(h0), 0, trRan, 0)

    def IsValidPosition(tu):
        idx, point = tu
        if generated_densities[idx] == d1:
            return False
        return not inPointOfInterest(point)

    if mobility:
        nr_nodes = len(positions)
        print "Generating mobility"
        filename = "n_{0}_d_{1}_tr_{2}_a_{3}x{4}_idx_{5}.mobility".format(nr_nodes, 0, trRan, int(w0), int(h0), 0)
        while True:
            b = genmobility.generateMobility(sps=10, nr_nodes=nr_nodes,
                                             map_x=int(w0), map_y=int(h0),
                                             sim_time=600, positions=positions,
                                            #  mobility_map=mobility_map,
                                             outputFile=filename,
                                            #  testValidPosition=IsValidPosition,
                                             test=get_still_connected_callback(trRan, idx_source))
            if b:
                break

    kdTree.generate_image(None, w0, h0, "topology{}.png".format(0), positions, False)
    pass


def build_non_uniform_topologies(args, densities, nr_topologies):
    trRan = args.tx
    mobility = args.mobility
    nr_sessions = args.nr_sessions

    d0 = densities[0]
    w, h = compute_map_size(trRan, int(args.nr_nodes/2.0), d0)
    rand = random.Random()
    for i in range(0, nr_topologies):
        print "w={}, h={}, tx={}".format(w, h, trRan)
        tree = kdTree.generate_tree(map_w=w, map_h=h, min_size=2*trRan, min_number_leaf=2)
        leafs = tree.apply_to_each_leaf(lambda node: node)

        A = w * h
        n = int(args.nr_nodes)
        positions = []
        generated_densities = []
        random.shuffle(leafs)
        for node in leafs:
            final_idx = find_top_density(densities, node, A, trRan, n, d0)
            if final_idx < 0:
                continue
            idx = rand.randint(0, final_idx)
            d = densities[idx]
            print "Using density {}".format(d)
            node.density = d
            p, n1 = fillSurfaceWithFixedRadioAndSize(trRan, node.x, node.y, node.w, node.h, d)
            positions.extend(p)
            generated_densities.extend([d for ii in range(0, len(p))])
            n = n - n1
            A = A - node.w*node.h
            if n < 0 or A <= 0:
                break

        # assign missing nodes
        for j in range(0, n):
            x, y = rand.randint(0, w), rand.randint(0, h)
            positions.append([x, y])
            generated_densities.append(tree.find_leaf(x, y).density)

        print "Fixing connectivity"
        connected = guarentee_connectivity(positions, trRan)

        print "{} nodes unassigned".format(n)

        create_nedfile(positions, int(w), int(w), i+1, args)
        create_density_file(generated_densities, int(w), int(h), i+1, args.tx, 0)

        kdTree.save_tree_as_image(tree=tree, image_filename="topology{}.png".format(i), positions=positions)
        kdTree.save_tree_as_image(tree=tree, image_filename="topology_colours{}.png".format(i), positions=positions, colorful_densities=True)
    pass


if __name__ == '__main__':
    args = get_arguments()
    min_density = args.min_density
    max_density = args.max_density
    non_uniform = args.non_uniform
    handcrafted = args.handcrafted

    step = 5
    densities = range(min_density, max_density + step, step)

    if non_uniform:
        build_non_uniform_topologies(args, densities, nr_topologies=1)
    elif handcrafted:
	    build_handcrafted_topology(args, [min_density, max_density], 4)
    else:
        build_uniform_topologies(args, densities)


    print "Done"
