#include "StoredMobility.h"

#include <iostream>
#include <fstream>
#include <map>

#include <algorithm>
#include <memory>

using namespace std;

namespace inet {

Define_Module(StoredMovingMobility);

class StoredMobility {
  public:
    static std::shared_ptr<StoredMobility> getInstance(std::string& str);

    void readNodeMobilities();
    NodeStoredMobility getMobility(int idx);

    StoredMobility(std::string& f) :filename(f) { };

  private:
    bool read = false;
    std::string filename;
    vector<NodeStoredMobility> mobility;
    static std::map<string, std::shared_ptr<StoredMobility> > instances;
};


map<string, shared_ptr<StoredMobility> > StoredMobility::instances;

void
NodeStoredMobility::add_location(double x, double y)
{
	locations.push_back(make_pair(x, y));
}

pair<double, double>
NodeStoredMobility::get_next_location()
{
	if (locations.size() == 0) {
		throw runtime_error("no more locations");
	}
	auto p = locations.back();
	locations.pop_back();
	return p;
}

void
NodeStoredMobility::done_reading()
{
	reverse(locations.begin(), locations.end());
}

bool
NodeStoredMobility::hasMoreLocations()
{
	return locations.size() > 0;
}

shared_ptr<StoredMobility>
StoredMobility::getInstance(string& str)
{
	if (instances.find(str) == instances.end()) {
		instances[str] = make_shared<StoredMobility>(str);
	}
	return instances[str];
}

void
StoredMobility::readNodeMobilities()
{

  if (read) return;

	ifstream ifs(filename);
	string line;
	getline(ifs, line); // number of nodes
	int nr_nodes = stoi(line);
	getline(ifs, line); // time step in seconds
	double time_step = stod(line);
	for (int i = 0 ; i < nr_nodes; i++) {
		mobility.push_back(NodeStoredMobility(time_step));
	}

	do {
		for (int i = 0 ; i < nr_nodes; i++ ) {
			getline(ifs, line);
			if (line.empty()) break;
			// cout << "a line |" << line << "|" << endl;
			auto pos = line.find(" ");
			double x = stod(line.substr(0, pos));
			double y = stod(line.substr(pos+1, string::npos));
			mobility[i].add_location(x, y);
		}
	} while (!ifs.eof());

	for (auto& node : mobility) {
		node.done_reading();
	}

  read = true;

}

NodeStoredMobility
StoredMobility::getMobility(int idx)
{
  return mobility[idx];
}


void
StoredMovingMobility::initialize(int stage)
{

    EV_TRACE << "initializing StoredMovingMobility stage " << stage << endl;
    if (stage == INITSTAGE_LOCAL) {
        MovingMobilityBase::initialize(stage);
        moveTimer = new cMessage("move");
        isMoving = par("isMoving").boolValue();
        filename = par("filename").stdstringValue();

        cModule* host = getContainingNode(this);
        string hostName = this->getParentModule()->getFullName();
        int idx = stoi(hostName.substr( string("hostR").size(), string::npos));
        cout << "XXXXXXXXXXXXXXXXXXXXXXXXX" << hostName << " " << idx <<  " " << filename << endl;

        if (isMoving) {
          auto m = StoredMobility::getInstance(filename);
          m->readNodeMobilities();
          int idx = 0;
          mobility = m->getMobility(idx);
        }
    }
    else if (stage == INITSTAGE_PHYSICAL_ENVIRONMENT_2) {
      lastPosition = Coord(0, 1);
      cModule* host = getContainingNode(this);
      string hostName = this->getParentModule()->getFullName();
      emitMobilityStateChangedSignal();
      updateVisualRepresentation();
    }
}

void
StoredMovingMobility::move()
{
  //auto l = mobility.get_next_location();
  //lastPosition = Coord(l.first, l.second);
  // lastSpeed
  nextChange = simTime() + mobility.get_time_step();
}

} // namespace
