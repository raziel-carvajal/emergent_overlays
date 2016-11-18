//
// Generated file, do not edit! Created by nedtool 4.6 from cds/cdsMsgs.msg.
//

// Disable warnings about unused variables, empty switch stmts, etc:
#ifdef _MSC_VER
#  pragma warning(disable:4101)
#  pragma warning(disable:4065)
#endif

#include <iostream>
#include <sstream>
#include "cdsMsgs_m.h"

USING_NAMESPACE


// Another default rule (prevents compiler from choosing base class' doPacking())
template<typename T>
void doPacking(cCommBuffer *, T& t) {
    throw cRuntimeError("Parsim error: no doPacking() function for type %s or its base class (check .msg and _m.cc/h files!)",opp_typename(typeid(t)));
}

template<typename T>
void doUnpacking(cCommBuffer *, T& t) {
    throw cRuntimeError("Parsim error: no doUnpacking() function for type %s or its base class (check .msg and _m.cc/h files!)",opp_typename(typeid(t)));
}



namespace inet {
namespace cds2 {

// Template rule for outputting std::vector<T> types
template<typename T, typename A>
inline std::ostream& operator<<(std::ostream& out, const std::vector<T,A>& vec)
{
    out.put('{');
    for(typename std::vector<T,A>::const_iterator it = vec.begin(); it != vec.end(); ++it)
    {
        if (it != vec.begin()) {
            out.put(','); out.put(' ');
        }
        out << *it;
    }
    out.put('}');
    
    char buf[32];
    sprintf(buf, " (size=%u)", (unsigned int)vec.size());
    out.write(buf, strlen(buf));
    return out;
}

// Template rule which fires if a struct or class doesn't have operator<<
template<typename T>
inline std::ostream& operator<<(std::ostream& out,const T&) {return out;}

Register_Class(Neighbors);

Neighbors::Neighbors(const char *name, int kind) : ::cPacket(name,kind)
{
    neighbors_arraysize = 0;
    this->neighbors_var = 0;
    hopLevels_arraysize = 0;
    this->hopLevels_var = 0;
    xs_arraysize = 0;
    this->xs_var = 0;
    ys_arraysize = 0;
    this->ys_var = 0;
    this->maxHopLevel_var = 0;
    this->sender_var = 0;
    this->x_var = 0;
    this->y_var = 0;
}

Neighbors::Neighbors(const Neighbors& other) : ::cPacket(other)
{
    neighbors_arraysize = 0;
    this->neighbors_var = 0;
    hopLevels_arraysize = 0;
    this->hopLevels_var = 0;
    xs_arraysize = 0;
    this->xs_var = 0;
    ys_arraysize = 0;
    this->ys_var = 0;
    copy(other);
}

Neighbors::~Neighbors()
{
    delete [] neighbors_var;
    delete [] hopLevels_var;
    delete [] xs_var;
    delete [] ys_var;
}

Neighbors& Neighbors::operator=(const Neighbors& other)
{
    if (this==&other) return *this;
    ::cPacket::operator=(other);
    copy(other);
    return *this;
}

void Neighbors::copy(const Neighbors& other)
{
    delete [] this->neighbors_var;
    this->neighbors_var = (other.neighbors_arraysize==0) ? NULL : new opp_string[other.neighbors_arraysize];
    neighbors_arraysize = other.neighbors_arraysize;
    for (unsigned int i=0; i<neighbors_arraysize; i++)
        this->neighbors_var[i] = other.neighbors_var[i];
    delete [] this->hopLevels_var;
    this->hopLevels_var = (other.hopLevels_arraysize==0) ? NULL : new int[other.hopLevels_arraysize];
    hopLevels_arraysize = other.hopLevels_arraysize;
    for (unsigned int i=0; i<hopLevels_arraysize; i++)
        this->hopLevels_var[i] = other.hopLevels_var[i];
    delete [] this->xs_var;
    this->xs_var = (other.xs_arraysize==0) ? NULL : new double[other.xs_arraysize];
    xs_arraysize = other.xs_arraysize;
    for (unsigned int i=0; i<xs_arraysize; i++)
        this->xs_var[i] = other.xs_var[i];
    delete [] this->ys_var;
    this->ys_var = (other.ys_arraysize==0) ? NULL : new double[other.ys_arraysize];
    ys_arraysize = other.ys_arraysize;
    for (unsigned int i=0; i<ys_arraysize; i++)
        this->ys_var[i] = other.ys_var[i];
    this->maxHopLevel_var = other.maxHopLevel_var;
    this->sender_var = other.sender_var;
    this->x_var = other.x_var;
    this->y_var = other.y_var;
}

void Neighbors::parsimPack(cCommBuffer *b)
{
    ::cPacket::parsimPack(b);
    b->pack(neighbors_arraysize);
    doPacking(b,this->neighbors_var,neighbors_arraysize);
    b->pack(hopLevels_arraysize);
    doPacking(b,this->hopLevels_var,hopLevels_arraysize);
    b->pack(xs_arraysize);
    doPacking(b,this->xs_var,xs_arraysize);
    b->pack(ys_arraysize);
    doPacking(b,this->ys_var,ys_arraysize);
    doPacking(b,this->maxHopLevel_var);
    doPacking(b,this->sender_var);
    doPacking(b,this->x_var);
    doPacking(b,this->y_var);
}

void Neighbors::parsimUnpack(cCommBuffer *b)
{
    ::cPacket::parsimUnpack(b);
    delete [] this->neighbors_var;
    b->unpack(neighbors_arraysize);
    if (neighbors_arraysize==0) {
        this->neighbors_var = 0;
    } else {
        this->neighbors_var = new opp_string[neighbors_arraysize];
        doUnpacking(b,this->neighbors_var,neighbors_arraysize);
    }
    delete [] this->hopLevels_var;
    b->unpack(hopLevels_arraysize);
    if (hopLevels_arraysize==0) {
        this->hopLevels_var = 0;
    } else {
        this->hopLevels_var = new int[hopLevels_arraysize];
        doUnpacking(b,this->hopLevels_var,hopLevels_arraysize);
    }
    delete [] this->xs_var;
    b->unpack(xs_arraysize);
    if (xs_arraysize==0) {
        this->xs_var = 0;
    } else {
        this->xs_var = new double[xs_arraysize];
        doUnpacking(b,this->xs_var,xs_arraysize);
    }
    delete [] this->ys_var;
    b->unpack(ys_arraysize);
    if (ys_arraysize==0) {
        this->ys_var = 0;
    } else {
        this->ys_var = new double[ys_arraysize];
        doUnpacking(b,this->ys_var,ys_arraysize);
    }
    doUnpacking(b,this->maxHopLevel_var);
    doUnpacking(b,this->sender_var);
    doUnpacking(b,this->x_var);
    doUnpacking(b,this->y_var);
}

void Neighbors::setNeighborsArraySize(unsigned int size)
{
    opp_string *neighbors_var2 = (size==0) ? NULL : new opp_string[size];
    unsigned int sz = neighbors_arraysize < size ? neighbors_arraysize : size;
    for (unsigned int i=0; i<sz; i++)
        neighbors_var2[i] = this->neighbors_var[i];
    for (unsigned int i=sz; i<size; i++)
        neighbors_var2[i] = 0;
    neighbors_arraysize = size;
    delete [] this->neighbors_var;
    this->neighbors_var = neighbors_var2;
}

unsigned int Neighbors::getNeighborsArraySize() const
{
    return neighbors_arraysize;
}

const char * Neighbors::getNeighbors(unsigned int k) const
{
    if (k>=neighbors_arraysize) throw cRuntimeError("Array of size %d indexed by %d", neighbors_arraysize, k);
    return neighbors_var[k].c_str();
}

void Neighbors::setNeighbors(unsigned int k, const char * neighbors)
{
    if (k>=neighbors_arraysize) throw cRuntimeError("Array of size %d indexed by %d", neighbors_arraysize, k);
    this->neighbors_var[k] = neighbors;
}

void Neighbors::setHopLevelsArraySize(unsigned int size)
{
    int *hopLevels_var2 = (size==0) ? NULL : new int[size];
    unsigned int sz = hopLevels_arraysize < size ? hopLevels_arraysize : size;
    for (unsigned int i=0; i<sz; i++)
        hopLevels_var2[i] = this->hopLevels_var[i];
    for (unsigned int i=sz; i<size; i++)
        hopLevels_var2[i] = 0;
    hopLevels_arraysize = size;
    delete [] this->hopLevels_var;
    this->hopLevels_var = hopLevels_var2;
}

unsigned int Neighbors::getHopLevelsArraySize() const
{
    return hopLevels_arraysize;
}

int Neighbors::getHopLevels(unsigned int k) const
{
    if (k>=hopLevels_arraysize) throw cRuntimeError("Array of size %d indexed by %d", hopLevels_arraysize, k);
    return hopLevels_var[k];
}

void Neighbors::setHopLevels(unsigned int k, int hopLevels)
{
    if (k>=hopLevels_arraysize) throw cRuntimeError("Array of size %d indexed by %d", hopLevels_arraysize, k);
    this->hopLevels_var[k] = hopLevels;
}

void Neighbors::setXsArraySize(unsigned int size)
{
    double *xs_var2 = (size==0) ? NULL : new double[size];
    unsigned int sz = xs_arraysize < size ? xs_arraysize : size;
    for (unsigned int i=0; i<sz; i++)
        xs_var2[i] = this->xs_var[i];
    for (unsigned int i=sz; i<size; i++)
        xs_var2[i] = 0;
    xs_arraysize = size;
    delete [] this->xs_var;
    this->xs_var = xs_var2;
}

unsigned int Neighbors::getXsArraySize() const
{
    return xs_arraysize;
}

double Neighbors::getXs(unsigned int k) const
{
    if (k>=xs_arraysize) throw cRuntimeError("Array of size %d indexed by %d", xs_arraysize, k);
    return xs_var[k];
}

void Neighbors::setXs(unsigned int k, double xs)
{
    if (k>=xs_arraysize) throw cRuntimeError("Array of size %d indexed by %d", xs_arraysize, k);
    this->xs_var[k] = xs;
}

void Neighbors::setYsArraySize(unsigned int size)
{
    double *ys_var2 = (size==0) ? NULL : new double[size];
    unsigned int sz = ys_arraysize < size ? ys_arraysize : size;
    for (unsigned int i=0; i<sz; i++)
        ys_var2[i] = this->ys_var[i];
    for (unsigned int i=sz; i<size; i++)
        ys_var2[i] = 0;
    ys_arraysize = size;
    delete [] this->ys_var;
    this->ys_var = ys_var2;
}

unsigned int Neighbors::getYsArraySize() const
{
    return ys_arraysize;
}

double Neighbors::getYs(unsigned int k) const
{
    if (k>=ys_arraysize) throw cRuntimeError("Array of size %d indexed by %d", ys_arraysize, k);
    return ys_var[k];
}

void Neighbors::setYs(unsigned int k, double ys)
{
    if (k>=ys_arraysize) throw cRuntimeError("Array of size %d indexed by %d", ys_arraysize, k);
    this->ys_var[k] = ys;
}

int Neighbors::getMaxHopLevel() const
{
    return maxHopLevel_var;
}

void Neighbors::setMaxHopLevel(int maxHopLevel)
{
    this->maxHopLevel_var = maxHopLevel;
}

const char * Neighbors::getSender() const
{
    return sender_var.c_str();
}

void Neighbors::setSender(const char * sender)
{
    this->sender_var = sender;
}

double Neighbors::getX() const
{
    return x_var;
}

void Neighbors::setX(double x)
{
    this->x_var = x;
}

double Neighbors::getY() const
{
    return y_var;
}

void Neighbors::setY(double y)
{
    this->y_var = y;
}

class NeighborsDescriptor : public cClassDescriptor
{
  public:
    NeighborsDescriptor();
    virtual ~NeighborsDescriptor();

    virtual bool doesSupport(cObject *obj) const;
    virtual const char *getProperty(const char *propertyname) const;
    virtual int getFieldCount(void *object) const;
    virtual const char *getFieldName(void *object, int field) const;
    virtual int findField(void *object, const char *fieldName) const;
    virtual unsigned int getFieldTypeFlags(void *object, int field) const;
    virtual const char *getFieldTypeString(void *object, int field) const;
    virtual const char *getFieldProperty(void *object, int field, const char *propertyname) const;
    virtual int getArraySize(void *object, int field) const;

    virtual std::string getFieldAsString(void *object, int field, int i) const;
    virtual bool setFieldAsString(void *object, int field, int i, const char *value) const;

    virtual const char *getFieldStructName(void *object, int field) const;
    virtual void *getFieldStructPointer(void *object, int field, int i) const;
};

Register_ClassDescriptor(NeighborsDescriptor);

NeighborsDescriptor::NeighborsDescriptor() : cClassDescriptor("inet::cds2::Neighbors", "cPacket")
{
}

NeighborsDescriptor::~NeighborsDescriptor()
{
}

bool NeighborsDescriptor::doesSupport(cObject *obj) const
{
    return dynamic_cast<Neighbors *>(obj)!=NULL;
}

const char *NeighborsDescriptor::getProperty(const char *propertyname) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    return basedesc ? basedesc->getProperty(propertyname) : NULL;
}

int NeighborsDescriptor::getFieldCount(void *object) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    return basedesc ? 8+basedesc->getFieldCount(object) : 8;
}

unsigned int NeighborsDescriptor::getFieldTypeFlags(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldTypeFlags(object, field);
        field -= basedesc->getFieldCount(object);
    }
    static unsigned int fieldTypeFlags[] = {
        FD_ISARRAY | FD_ISEDITABLE,
        FD_ISARRAY | FD_ISEDITABLE,
        FD_ISARRAY | FD_ISEDITABLE,
        FD_ISARRAY | FD_ISEDITABLE,
        FD_ISEDITABLE,
        FD_ISEDITABLE,
        FD_ISEDITABLE,
        FD_ISEDITABLE,
    };
    return (field>=0 && field<8) ? fieldTypeFlags[field] : 0;
}

const char *NeighborsDescriptor::getFieldName(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldName(object, field);
        field -= basedesc->getFieldCount(object);
    }
    static const char *fieldNames[] = {
        "neighbors",
        "hopLevels",
        "xs",
        "ys",
        "maxHopLevel",
        "sender",
        "x",
        "y",
    };
    return (field>=0 && field<8) ? fieldNames[field] : NULL;
}

int NeighborsDescriptor::findField(void *object, const char *fieldName) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    int base = basedesc ? basedesc->getFieldCount(object) : 0;
    if (fieldName[0]=='n' && strcmp(fieldName, "neighbors")==0) return base+0;
    if (fieldName[0]=='h' && strcmp(fieldName, "hopLevels")==0) return base+1;
    if (fieldName[0]=='x' && strcmp(fieldName, "xs")==0) return base+2;
    if (fieldName[0]=='y' && strcmp(fieldName, "ys")==0) return base+3;
    if (fieldName[0]=='m' && strcmp(fieldName, "maxHopLevel")==0) return base+4;
    if (fieldName[0]=='s' && strcmp(fieldName, "sender")==0) return base+5;
    if (fieldName[0]=='x' && strcmp(fieldName, "x")==0) return base+6;
    if (fieldName[0]=='y' && strcmp(fieldName, "y")==0) return base+7;
    return basedesc ? basedesc->findField(object, fieldName) : -1;
}

const char *NeighborsDescriptor::getFieldTypeString(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldTypeString(object, field);
        field -= basedesc->getFieldCount(object);
    }
    static const char *fieldTypeStrings[] = {
        "string",
        "int",
        "double",
        "double",
        "int",
        "string",
        "double",
        "double",
    };
    return (field>=0 && field<8) ? fieldTypeStrings[field] : NULL;
}

const char *NeighborsDescriptor::getFieldProperty(void *object, int field, const char *propertyname) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldProperty(object, field, propertyname);
        field -= basedesc->getFieldCount(object);
    }
    switch (field) {
        default: return NULL;
    }
}

int NeighborsDescriptor::getArraySize(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getArraySize(object, field);
        field -= basedesc->getFieldCount(object);
    }
    Neighbors *pp = (Neighbors *)object; (void)pp;
    switch (field) {
        case 0: return pp->getNeighborsArraySize();
        case 1: return pp->getHopLevelsArraySize();
        case 2: return pp->getXsArraySize();
        case 3: return pp->getYsArraySize();
        default: return 0;
    }
}

std::string NeighborsDescriptor::getFieldAsString(void *object, int field, int i) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldAsString(object,field,i);
        field -= basedesc->getFieldCount(object);
    }
    Neighbors *pp = (Neighbors *)object; (void)pp;
    switch (field) {
        case 0: return oppstring2string(pp->getNeighbors(i));
        case 1: return long2string(pp->getHopLevels(i));
        case 2: return double2string(pp->getXs(i));
        case 3: return double2string(pp->getYs(i));
        case 4: return long2string(pp->getMaxHopLevel());
        case 5: return oppstring2string(pp->getSender());
        case 6: return double2string(pp->getX());
        case 7: return double2string(pp->getY());
        default: return "";
    }
}

bool NeighborsDescriptor::setFieldAsString(void *object, int field, int i, const char *value) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->setFieldAsString(object,field,i,value);
        field -= basedesc->getFieldCount(object);
    }
    Neighbors *pp = (Neighbors *)object; (void)pp;
    switch (field) {
        case 0: pp->setNeighbors(i,(value)); return true;
        case 1: pp->setHopLevels(i,string2long(value)); return true;
        case 2: pp->setXs(i,string2double(value)); return true;
        case 3: pp->setYs(i,string2double(value)); return true;
        case 4: pp->setMaxHopLevel(string2long(value)); return true;
        case 5: pp->setSender((value)); return true;
        case 6: pp->setX(string2double(value)); return true;
        case 7: pp->setY(string2double(value)); return true;
        default: return false;
    }
}

const char *NeighborsDescriptor::getFieldStructName(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldStructName(object, field);
        field -= basedesc->getFieldCount(object);
    }
    switch (field) {
        default: return NULL;
    };
}

void *NeighborsDescriptor::getFieldStructPointer(void *object, int field, int i) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldStructPointer(object, field, i);
        field -= basedesc->getFieldCount(object);
    }
    Neighbors *pp = (Neighbors *)object; (void)pp;
    switch (field) {
        default: return NULL;
    }
}

Register_Class(RequestNeighbors);

RequestNeighbors::RequestNeighbors(const char *name, int kind) : ::cPacket(name,kind)
{
    this->sender_var = 0;
    this->maxHopLevel_var = 0;
    this->x_var = 0;
    this->y_var = 0;
}

RequestNeighbors::RequestNeighbors(const RequestNeighbors& other) : ::cPacket(other)
{
    copy(other);
}

RequestNeighbors::~RequestNeighbors()
{
}

RequestNeighbors& RequestNeighbors::operator=(const RequestNeighbors& other)
{
    if (this==&other) return *this;
    ::cPacket::operator=(other);
    copy(other);
    return *this;
}

void RequestNeighbors::copy(const RequestNeighbors& other)
{
    this->sender_var = other.sender_var;
    this->maxHopLevel_var = other.maxHopLevel_var;
    this->x_var = other.x_var;
    this->y_var = other.y_var;
}

void RequestNeighbors::parsimPack(cCommBuffer *b)
{
    ::cPacket::parsimPack(b);
    doPacking(b,this->sender_var);
    doPacking(b,this->maxHopLevel_var);
    doPacking(b,this->x_var);
    doPacking(b,this->y_var);
}

void RequestNeighbors::parsimUnpack(cCommBuffer *b)
{
    ::cPacket::parsimUnpack(b);
    doUnpacking(b,this->sender_var);
    doUnpacking(b,this->maxHopLevel_var);
    doUnpacking(b,this->x_var);
    doUnpacking(b,this->y_var);
}

const char * RequestNeighbors::getSender() const
{
    return sender_var.c_str();
}

void RequestNeighbors::setSender(const char * sender)
{
    this->sender_var = sender;
}

int RequestNeighbors::getMaxHopLevel() const
{
    return maxHopLevel_var;
}

void RequestNeighbors::setMaxHopLevel(int maxHopLevel)
{
    this->maxHopLevel_var = maxHopLevel;
}

double RequestNeighbors::getX() const
{
    return x_var;
}

void RequestNeighbors::setX(double x)
{
    this->x_var = x;
}

double RequestNeighbors::getY() const
{
    return y_var;
}

void RequestNeighbors::setY(double y)
{
    this->y_var = y;
}

class RequestNeighborsDescriptor : public cClassDescriptor
{
  public:
    RequestNeighborsDescriptor();
    virtual ~RequestNeighborsDescriptor();

    virtual bool doesSupport(cObject *obj) const;
    virtual const char *getProperty(const char *propertyname) const;
    virtual int getFieldCount(void *object) const;
    virtual const char *getFieldName(void *object, int field) const;
    virtual int findField(void *object, const char *fieldName) const;
    virtual unsigned int getFieldTypeFlags(void *object, int field) const;
    virtual const char *getFieldTypeString(void *object, int field) const;
    virtual const char *getFieldProperty(void *object, int field, const char *propertyname) const;
    virtual int getArraySize(void *object, int field) const;

    virtual std::string getFieldAsString(void *object, int field, int i) const;
    virtual bool setFieldAsString(void *object, int field, int i, const char *value) const;

    virtual const char *getFieldStructName(void *object, int field) const;
    virtual void *getFieldStructPointer(void *object, int field, int i) const;
};

Register_ClassDescriptor(RequestNeighborsDescriptor);

RequestNeighborsDescriptor::RequestNeighborsDescriptor() : cClassDescriptor("inet::cds2::RequestNeighbors", "cPacket")
{
}

RequestNeighborsDescriptor::~RequestNeighborsDescriptor()
{
}

bool RequestNeighborsDescriptor::doesSupport(cObject *obj) const
{
    return dynamic_cast<RequestNeighbors *>(obj)!=NULL;
}

const char *RequestNeighborsDescriptor::getProperty(const char *propertyname) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    return basedesc ? basedesc->getProperty(propertyname) : NULL;
}

int RequestNeighborsDescriptor::getFieldCount(void *object) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    return basedesc ? 4+basedesc->getFieldCount(object) : 4;
}

unsigned int RequestNeighborsDescriptor::getFieldTypeFlags(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldTypeFlags(object, field);
        field -= basedesc->getFieldCount(object);
    }
    static unsigned int fieldTypeFlags[] = {
        FD_ISEDITABLE,
        FD_ISEDITABLE,
        FD_ISEDITABLE,
        FD_ISEDITABLE,
    };
    return (field>=0 && field<4) ? fieldTypeFlags[field] : 0;
}

const char *RequestNeighborsDescriptor::getFieldName(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldName(object, field);
        field -= basedesc->getFieldCount(object);
    }
    static const char *fieldNames[] = {
        "sender",
        "maxHopLevel",
        "x",
        "y",
    };
    return (field>=0 && field<4) ? fieldNames[field] : NULL;
}

int RequestNeighborsDescriptor::findField(void *object, const char *fieldName) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    int base = basedesc ? basedesc->getFieldCount(object) : 0;
    if (fieldName[0]=='s' && strcmp(fieldName, "sender")==0) return base+0;
    if (fieldName[0]=='m' && strcmp(fieldName, "maxHopLevel")==0) return base+1;
    if (fieldName[0]=='x' && strcmp(fieldName, "x")==0) return base+2;
    if (fieldName[0]=='y' && strcmp(fieldName, "y")==0) return base+3;
    return basedesc ? basedesc->findField(object, fieldName) : -1;
}

const char *RequestNeighborsDescriptor::getFieldTypeString(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldTypeString(object, field);
        field -= basedesc->getFieldCount(object);
    }
    static const char *fieldTypeStrings[] = {
        "string",
        "int",
        "double",
        "double",
    };
    return (field>=0 && field<4) ? fieldTypeStrings[field] : NULL;
}

const char *RequestNeighborsDescriptor::getFieldProperty(void *object, int field, const char *propertyname) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldProperty(object, field, propertyname);
        field -= basedesc->getFieldCount(object);
    }
    switch (field) {
        default: return NULL;
    }
}

int RequestNeighborsDescriptor::getArraySize(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getArraySize(object, field);
        field -= basedesc->getFieldCount(object);
    }
    RequestNeighbors *pp = (RequestNeighbors *)object; (void)pp;
    switch (field) {
        default: return 0;
    }
}

std::string RequestNeighborsDescriptor::getFieldAsString(void *object, int field, int i) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldAsString(object,field,i);
        field -= basedesc->getFieldCount(object);
    }
    RequestNeighbors *pp = (RequestNeighbors *)object; (void)pp;
    switch (field) {
        case 0: return oppstring2string(pp->getSender());
        case 1: return long2string(pp->getMaxHopLevel());
        case 2: return double2string(pp->getX());
        case 3: return double2string(pp->getY());
        default: return "";
    }
}

bool RequestNeighborsDescriptor::setFieldAsString(void *object, int field, int i, const char *value) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->setFieldAsString(object,field,i,value);
        field -= basedesc->getFieldCount(object);
    }
    RequestNeighbors *pp = (RequestNeighbors *)object; (void)pp;
    switch (field) {
        case 0: pp->setSender((value)); return true;
        case 1: pp->setMaxHopLevel(string2long(value)); return true;
        case 2: pp->setX(string2double(value)); return true;
        case 3: pp->setY(string2double(value)); return true;
        default: return false;
    }
}

const char *RequestNeighborsDescriptor::getFieldStructName(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldStructName(object, field);
        field -= basedesc->getFieldCount(object);
    }
    switch (field) {
        default: return NULL;
    };
}

void *RequestNeighborsDescriptor::getFieldStructPointer(void *object, int field, int i) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldStructPointer(object, field, i);
        field -= basedesc->getFieldCount(object);
    }
    RequestNeighbors *pp = (RequestNeighbors *)object; (void)pp;
    switch (field) {
        default: return NULL;
    }
}

Register_Class(MarkerChanged);

MarkerChanged::MarkerChanged(const char *name, int kind) : ::cPacket(name,kind)
{
    this->sender_var = 0;
    this->marker_var = 0;
}

MarkerChanged::MarkerChanged(const MarkerChanged& other) : ::cPacket(other)
{
    copy(other);
}

MarkerChanged::~MarkerChanged()
{
}

MarkerChanged& MarkerChanged::operator=(const MarkerChanged& other)
{
    if (this==&other) return *this;
    ::cPacket::operator=(other);
    copy(other);
    return *this;
}

void MarkerChanged::copy(const MarkerChanged& other)
{
    this->sender_var = other.sender_var;
    this->marker_var = other.marker_var;
}

void MarkerChanged::parsimPack(cCommBuffer *b)
{
    ::cPacket::parsimPack(b);
    doPacking(b,this->sender_var);
    doPacking(b,this->marker_var);
}

void MarkerChanged::parsimUnpack(cCommBuffer *b)
{
    ::cPacket::parsimUnpack(b);
    doUnpacking(b,this->sender_var);
    doUnpacking(b,this->marker_var);
}

const char * MarkerChanged::getSender() const
{
    return sender_var.c_str();
}

void MarkerChanged::setSender(const char * sender)
{
    this->sender_var = sender;
}

bool MarkerChanged::getMarker() const
{
    return marker_var;
}

void MarkerChanged::setMarker(bool marker)
{
    this->marker_var = marker;
}

class MarkerChangedDescriptor : public cClassDescriptor
{
  public:
    MarkerChangedDescriptor();
    virtual ~MarkerChangedDescriptor();

    virtual bool doesSupport(cObject *obj) const;
    virtual const char *getProperty(const char *propertyname) const;
    virtual int getFieldCount(void *object) const;
    virtual const char *getFieldName(void *object, int field) const;
    virtual int findField(void *object, const char *fieldName) const;
    virtual unsigned int getFieldTypeFlags(void *object, int field) const;
    virtual const char *getFieldTypeString(void *object, int field) const;
    virtual const char *getFieldProperty(void *object, int field, const char *propertyname) const;
    virtual int getArraySize(void *object, int field) const;

    virtual std::string getFieldAsString(void *object, int field, int i) const;
    virtual bool setFieldAsString(void *object, int field, int i, const char *value) const;

    virtual const char *getFieldStructName(void *object, int field) const;
    virtual void *getFieldStructPointer(void *object, int field, int i) const;
};

Register_ClassDescriptor(MarkerChangedDescriptor);

MarkerChangedDescriptor::MarkerChangedDescriptor() : cClassDescriptor("inet::cds2::MarkerChanged", "cPacket")
{
}

MarkerChangedDescriptor::~MarkerChangedDescriptor()
{
}

bool MarkerChangedDescriptor::doesSupport(cObject *obj) const
{
    return dynamic_cast<MarkerChanged *>(obj)!=NULL;
}

const char *MarkerChangedDescriptor::getProperty(const char *propertyname) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    return basedesc ? basedesc->getProperty(propertyname) : NULL;
}

int MarkerChangedDescriptor::getFieldCount(void *object) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    return basedesc ? 2+basedesc->getFieldCount(object) : 2;
}

unsigned int MarkerChangedDescriptor::getFieldTypeFlags(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldTypeFlags(object, field);
        field -= basedesc->getFieldCount(object);
    }
    static unsigned int fieldTypeFlags[] = {
        FD_ISEDITABLE,
        FD_ISEDITABLE,
    };
    return (field>=0 && field<2) ? fieldTypeFlags[field] : 0;
}

const char *MarkerChangedDescriptor::getFieldName(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldName(object, field);
        field -= basedesc->getFieldCount(object);
    }
    static const char *fieldNames[] = {
        "sender",
        "marker",
    };
    return (field>=0 && field<2) ? fieldNames[field] : NULL;
}

int MarkerChangedDescriptor::findField(void *object, const char *fieldName) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    int base = basedesc ? basedesc->getFieldCount(object) : 0;
    if (fieldName[0]=='s' && strcmp(fieldName, "sender")==0) return base+0;
    if (fieldName[0]=='m' && strcmp(fieldName, "marker")==0) return base+1;
    return basedesc ? basedesc->findField(object, fieldName) : -1;
}

const char *MarkerChangedDescriptor::getFieldTypeString(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldTypeString(object, field);
        field -= basedesc->getFieldCount(object);
    }
    static const char *fieldTypeStrings[] = {
        "string",
        "bool",
    };
    return (field>=0 && field<2) ? fieldTypeStrings[field] : NULL;
}

const char *MarkerChangedDescriptor::getFieldProperty(void *object, int field, const char *propertyname) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldProperty(object, field, propertyname);
        field -= basedesc->getFieldCount(object);
    }
    switch (field) {
        default: return NULL;
    }
}

int MarkerChangedDescriptor::getArraySize(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getArraySize(object, field);
        field -= basedesc->getFieldCount(object);
    }
    MarkerChanged *pp = (MarkerChanged *)object; (void)pp;
    switch (field) {
        default: return 0;
    }
}

std::string MarkerChangedDescriptor::getFieldAsString(void *object, int field, int i) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldAsString(object,field,i);
        field -= basedesc->getFieldCount(object);
    }
    MarkerChanged *pp = (MarkerChanged *)object; (void)pp;
    switch (field) {
        case 0: return oppstring2string(pp->getSender());
        case 1: return bool2string(pp->getMarker());
        default: return "";
    }
}

bool MarkerChangedDescriptor::setFieldAsString(void *object, int field, int i, const char *value) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->setFieldAsString(object,field,i,value);
        field -= basedesc->getFieldCount(object);
    }
    MarkerChanged *pp = (MarkerChanged *)object; (void)pp;
    switch (field) {
        case 0: pp->setSender((value)); return true;
        case 1: pp->setMarker(string2bool(value)); return true;
        default: return false;
    }
}

const char *MarkerChangedDescriptor::getFieldStructName(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldStructName(object, field);
        field -= basedesc->getFieldCount(object);
    }
    switch (field) {
        default: return NULL;
    };
}

void *MarkerChangedDescriptor::getFieldStructPointer(void *object, int field, int i) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldStructPointer(object, field, i);
        field -= basedesc->getFieldCount(object);
    }
    MarkerChanged *pp = (MarkerChanged *)object; (void)pp;
    switch (field) {
        default: return NULL;
    }
}

} // namespace cds2
} // namespace inet

