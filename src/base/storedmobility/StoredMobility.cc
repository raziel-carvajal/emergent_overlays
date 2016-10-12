#include "StoredMobility.h"

#include <iostream>
#include <fstream>
#include <map>

#include <algorithm>
#include <memory>

#include <execinfo.h>
#include <stdlib.h>

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
  MovingMobilityBase::initialize(stage);
  if (stage == INITSTAGE_LOCAL) {

    moveTimer = new cMessage("move");
    isMoving = par("isMoving").boolValue();
    filename = par("filename").stdstringValue();

    cModule* host = getContainingNode(this);
    string hostName = this->getParentModule()->getFullName();
    auto id = hostName.substr( string("hostR").length(), string::npos);
    int idx = stoi(id);
    lastSpeed = Coord::ZERO;

    if (isMoving) {
      auto m = StoredMobility::getInstance(filename);
      m->readNodeMobilities();
      mobility = m->getMobility(idx);
    }
    stationary = !isMoving;
    if (stationary) {
      nextChange = -1;
    }
  }
  else if (stage == INITSTAGE_PHYSICAL_ENVIRONMENT_2) {
    if (isMoving) {
      auto l = mobility.get_next_location();
      lastPosition = Coord(l.first, l.second);
      emitMobilityStateChangedSignal();
    }
    else {
      visualRepresentation = findVisualRepresentation();
      if (visualRepresentation) {
        string x = visualRepresentation->getDisplayString().getTagArg("p", 0);
        string y = visualRepresentation->getDisplayString().getTagArg("p", 1);
        lastPosition.x = stod(x);
        lastPosition.y = stod(y);
        lastPosition.z = 0;
        EV_TRACE << " THIS IS VERY NICE " << lastPosition << endl;

      }
    }
  }
}

void StoredMovingMobility::handleSelfMessage(cMessage *message)
{
  if (isMoving)
    MovingMobilityBase::handleSelfMessage(message);
}

void
StoredMovingMobility::move()
{
  if (isMoving) {
    auto l = mobility.get_next_location();
    auto previousPosition = lastPosition;
    lastPosition = Coord(l.first, l.second);
    lastSpeed = (lastPosition - previousPosition);
    auto d = lastSpeed.length();
    auto v = d / mobility.get_time_step();
    lastSpeed.normalize();
    lastSpeed *= v;
    nextChange = simTime() + mobility.get_time_step();
  }
}

Coord StoredMovingMobility::getCurrentPosition()
{
  return (isMoving)? MovingMobilityBase::getCurrentPosition():lastPosition;
}

Coord StoredMovingMobility::getCurrentSpeed()
{
    return (isMoving)? MovingMobilityBase::getCurrentSpeed():lastSpeed;
}

} // namespace
