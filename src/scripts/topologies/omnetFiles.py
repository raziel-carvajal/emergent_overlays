from jinja2 import Environment, PackageLoader, select_autoescape


def createNedFile(denType, pos, index, layoutSizeW, layoutSizeH, Tx, callback_source):
    fileName = "n_{0}_d_{1}_tr_{2}_a_{3}x{4}_idx_{5}_p_.ned".format(len(pos), denType, Tx, layoutSizeW, layoutSizeH, index)

    class Net:
        def __init__(self, name, w, h, positions):
            self.name = name
            self.w = w
            self.h = h
            self.pos = positions
            self.positions = range(0, len(pos))

        def node_info(self, idx):
            p = self.pos[idx]
            s = callback_source(idx, p)
            print s
            return str('{}'.format(s))

    env = Environment(
        loader=PackageLoader('omnetFiles', ''),
        autoescape=False
    )

    template = env.get_template('topology.template')
    template
    config = template.render(network=Net(fileName, layoutSizeW, layoutSizeH, pos))
    with open(fileName, "w") as text_file:
        text_file.write("{0}".format(config))
