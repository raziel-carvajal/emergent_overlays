//
// Generated file, do not edit! Created by nedtool 4.6 from ewma2/ewmaMsgs.msg.
//

// Disable warnings about unused variables, empty switch stmts, etc:
#ifdef _MSC_VER
#  pragma warning(disable:4101)
#  pragma warning(disable:4065)
#endif

#include <iostream>
#include <sstream>
#include "ewmaMsgs_m.h"

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
namespace ewma {

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

Register_Class(EWMABroadcast);

EWMABroadcast::EWMABroadcast(const char *name, int kind) : ::inet::broadcasting::Broadcast(name,kind)
{
    covered_arraysize = 0;
    this->covered_var = 0;
}

EWMABroadcast::EWMABroadcast(const EWMABroadcast& other) : ::inet::broadcasting::Broadcast(other)
{
    covered_arraysize = 0;
    this->covered_var = 0;
    copy(other);
}

EWMABroadcast::~EWMABroadcast()
{
    delete [] covered_var;
}

EWMABroadcast& EWMABroadcast::operator=(const EWMABroadcast& other)
{
    if (this==&other) return *this;
    ::inet::broadcasting::Broadcast::operator=(other);
    copy(other);
    return *this;
}

void EWMABroadcast::copy(const EWMABroadcast& other)
{
    delete [] this->covered_var;
    this->covered_var = (other.covered_arraysize==0) ? NULL : new opp_string[other.covered_arraysize];
    covered_arraysize = other.covered_arraysize;
    for (unsigned int i=0; i<covered_arraysize; i++)
        this->covered_var[i] = other.covered_var[i];
}

void EWMABroadcast::parsimPack(cCommBuffer *b)
{
    ::inet::broadcasting::Broadcast::parsimPack(b);
    b->pack(covered_arraysize);
    doPacking(b,this->covered_var,covered_arraysize);
}

void EWMABroadcast::parsimUnpack(cCommBuffer *b)
{
    ::inet::broadcasting::Broadcast::parsimUnpack(b);
    delete [] this->covered_var;
    b->unpack(covered_arraysize);
    if (covered_arraysize==0) {
        this->covered_var = 0;
    } else {
        this->covered_var = new opp_string[covered_arraysize];
        doUnpacking(b,this->covered_var,covered_arraysize);
    }
}

void EWMABroadcast::setCoveredArraySize(unsigned int size)
{
    opp_string *covered_var2 = (size==0) ? NULL : new opp_string[size];
    unsigned int sz = covered_arraysize < size ? covered_arraysize : size;
    for (unsigned int i=0; i<sz; i++)
        covered_var2[i] = this->covered_var[i];
    for (unsigned int i=sz; i<size; i++)
        covered_var2[i] = 0;
    covered_arraysize = size;
    delete [] this->covered_var;
    this->covered_var = covered_var2;
}

unsigned int EWMABroadcast::getCoveredArraySize() const
{
    return covered_arraysize;
}

const char * EWMABroadcast::getCovered(unsigned int k) const
{
    if (k>=covered_arraysize) throw cRuntimeError("Array of size %d indexed by %d", covered_arraysize, k);
    return covered_var[k].c_str();
}

void EWMABroadcast::setCovered(unsigned int k, const char * covered)
{
    if (k>=covered_arraysize) throw cRuntimeError("Array of size %d indexed by %d", covered_arraysize, k);
    this->covered_var[k] = covered;
}

class EWMABroadcastDescriptor : public cClassDescriptor
{
  public:
    EWMABroadcastDescriptor();
    virtual ~EWMABroadcastDescriptor();

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

Register_ClassDescriptor(EWMABroadcastDescriptor);

EWMABroadcastDescriptor::EWMABroadcastDescriptor() : cClassDescriptor("inet::ewma::EWMABroadcast", "inet::broadcasting::Broadcast")
{
}

EWMABroadcastDescriptor::~EWMABroadcastDescriptor()
{
}

bool EWMABroadcastDescriptor::doesSupport(cObject *obj) const
{
    return dynamic_cast<EWMABroadcast *>(obj)!=NULL;
}

const char *EWMABroadcastDescriptor::getProperty(const char *propertyname) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    return basedesc ? basedesc->getProperty(propertyname) : NULL;
}

int EWMABroadcastDescriptor::getFieldCount(void *object) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    return basedesc ? 1+basedesc->getFieldCount(object) : 1;
}

unsigned int EWMABroadcastDescriptor::getFieldTypeFlags(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldTypeFlags(object, field);
        field -= basedesc->getFieldCount(object);
    }
    static unsigned int fieldTypeFlags[] = {
        FD_ISARRAY | FD_ISEDITABLE,
    };
    return (field>=0 && field<1) ? fieldTypeFlags[field] : 0;
}

const char *EWMABroadcastDescriptor::getFieldName(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldName(object, field);
        field -= basedesc->getFieldCount(object);
    }
    static const char *fieldNames[] = {
        "covered",
    };
    return (field>=0 && field<1) ? fieldNames[field] : NULL;
}

int EWMABroadcastDescriptor::findField(void *object, const char *fieldName) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    int base = basedesc ? basedesc->getFieldCount(object) : 0;
    if (fieldName[0]=='c' && strcmp(fieldName, "covered")==0) return base+0;
    return basedesc ? basedesc->findField(object, fieldName) : -1;
}

const char *EWMABroadcastDescriptor::getFieldTypeString(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldTypeString(object, field);
        field -= basedesc->getFieldCount(object);
    }
    static const char *fieldTypeStrings[] = {
        "string",
    };
    return (field>=0 && field<1) ? fieldTypeStrings[field] : NULL;
}

const char *EWMABroadcastDescriptor::getFieldProperty(void *object, int field, const char *propertyname) const
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

int EWMABroadcastDescriptor::getArraySize(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getArraySize(object, field);
        field -= basedesc->getFieldCount(object);
    }
    EWMABroadcast *pp = (EWMABroadcast *)object; (void)pp;
    switch (field) {
        case 0: return pp->getCoveredArraySize();
        default: return 0;
    }
}

std::string EWMABroadcastDescriptor::getFieldAsString(void *object, int field, int i) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldAsString(object,field,i);
        field -= basedesc->getFieldCount(object);
    }
    EWMABroadcast *pp = (EWMABroadcast *)object; (void)pp;
    switch (field) {
        case 0: return oppstring2string(pp->getCovered(i));
        default: return "";
    }
}

bool EWMABroadcastDescriptor::setFieldAsString(void *object, int field, int i, const char *value) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->setFieldAsString(object,field,i,value);
        field -= basedesc->getFieldCount(object);
    }
    EWMABroadcast *pp = (EWMABroadcast *)object; (void)pp;
    switch (field) {
        case 0: pp->setCovered(i,(value)); return true;
        default: return false;
    }
}

const char *EWMABroadcastDescriptor::getFieldStructName(void *object, int field) const
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

void *EWMABroadcastDescriptor::getFieldStructPointer(void *object, int field, int i) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldStructPointer(object, field, i);
        field -= basedesc->getFieldCount(object);
    }
    EWMABroadcast *pp = (EWMABroadcast *)object; (void)pp;
    switch (field) {
        default: return NULL;
    }
}

Register_Class(ConnectMWST);

ConnectMWST::ConnectMWST(const char *name, int kind) : ::cPacket(name,kind)
{
    this->sender_var = 0;
}

ConnectMWST::ConnectMWST(const ConnectMWST& other) : ::cPacket(other)
{
    copy(other);
}

ConnectMWST::~ConnectMWST()
{
}

ConnectMWST& ConnectMWST::operator=(const ConnectMWST& other)
{
    if (this==&other) return *this;
    ::cPacket::operator=(other);
    copy(other);
    return *this;
}

void ConnectMWST::copy(const ConnectMWST& other)
{
    this->sender_var = other.sender_var;
}

void ConnectMWST::parsimPack(cCommBuffer *b)
{
    ::cPacket::parsimPack(b);
    doPacking(b,this->sender_var);
}

void ConnectMWST::parsimUnpack(cCommBuffer *b)
{
    ::cPacket::parsimUnpack(b);
    doUnpacking(b,this->sender_var);
}

const char * ConnectMWST::getSender() const
{
    return sender_var.c_str();
}

void ConnectMWST::setSender(const char * sender)
{
    this->sender_var = sender;
}

class ConnectMWSTDescriptor : public cClassDescriptor
{
  public:
    ConnectMWSTDescriptor();
    virtual ~ConnectMWSTDescriptor();

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

Register_ClassDescriptor(ConnectMWSTDescriptor);

ConnectMWSTDescriptor::ConnectMWSTDescriptor() : cClassDescriptor("inet::ewma::ConnectMWST", "cPacket")
{
}

ConnectMWSTDescriptor::~ConnectMWSTDescriptor()
{
}

bool ConnectMWSTDescriptor::doesSupport(cObject *obj) const
{
    return dynamic_cast<ConnectMWST *>(obj)!=NULL;
}

const char *ConnectMWSTDescriptor::getProperty(const char *propertyname) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    return basedesc ? basedesc->getProperty(propertyname) : NULL;
}

int ConnectMWSTDescriptor::getFieldCount(void *object) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    return basedesc ? 1+basedesc->getFieldCount(object) : 1;
}

unsigned int ConnectMWSTDescriptor::getFieldTypeFlags(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldTypeFlags(object, field);
        field -= basedesc->getFieldCount(object);
    }
    static unsigned int fieldTypeFlags[] = {
        FD_ISEDITABLE,
    };
    return (field>=0 && field<1) ? fieldTypeFlags[field] : 0;
}

const char *ConnectMWSTDescriptor::getFieldName(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldName(object, field);
        field -= basedesc->getFieldCount(object);
    }
    static const char *fieldNames[] = {
        "sender",
    };
    return (field>=0 && field<1) ? fieldNames[field] : NULL;
}

int ConnectMWSTDescriptor::findField(void *object, const char *fieldName) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    int base = basedesc ? basedesc->getFieldCount(object) : 0;
    if (fieldName[0]=='s' && strcmp(fieldName, "sender")==0) return base+0;
    return basedesc ? basedesc->findField(object, fieldName) : -1;
}

const char *ConnectMWSTDescriptor::getFieldTypeString(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldTypeString(object, field);
        field -= basedesc->getFieldCount(object);
    }
    static const char *fieldTypeStrings[] = {
        "string",
    };
    return (field>=0 && field<1) ? fieldTypeStrings[field] : NULL;
}

const char *ConnectMWSTDescriptor::getFieldProperty(void *object, int field, const char *propertyname) const
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

int ConnectMWSTDescriptor::getArraySize(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getArraySize(object, field);
        field -= basedesc->getFieldCount(object);
    }
    ConnectMWST *pp = (ConnectMWST *)object; (void)pp;
    switch (field) {
        default: return 0;
    }
}

std::string ConnectMWSTDescriptor::getFieldAsString(void *object, int field, int i) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldAsString(object,field,i);
        field -= basedesc->getFieldCount(object);
    }
    ConnectMWST *pp = (ConnectMWST *)object; (void)pp;
    switch (field) {
        case 0: return oppstring2string(pp->getSender());
        default: return "";
    }
}

bool ConnectMWSTDescriptor::setFieldAsString(void *object, int field, int i, const char *value) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->setFieldAsString(object,field,i,value);
        field -= basedesc->getFieldCount(object);
    }
    ConnectMWST *pp = (ConnectMWST *)object; (void)pp;
    switch (field) {
        case 0: pp->setSender((value)); return true;
        default: return false;
    }
}

const char *ConnectMWSTDescriptor::getFieldStructName(void *object, int field) const
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

void *ConnectMWSTDescriptor::getFieldStructPointer(void *object, int field, int i) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldStructPointer(object, field, i);
        field -= basedesc->getFieldCount(object);
    }
    ConnectMWST *pp = (ConnectMWST *)object; (void)pp;
    switch (field) {
        default: return NULL;
    }
}

Register_Class(InitiateMWST);

InitiateMWST::InitiateMWST(const char *name, int kind) : ::cPacket(name,kind)
{
    this->fragmentId_var = 0;
    this->sender_var = 0;
}

InitiateMWST::InitiateMWST(const InitiateMWST& other) : ::cPacket(other)
{
    copy(other);
}

InitiateMWST::~InitiateMWST()
{
}

InitiateMWST& InitiateMWST::operator=(const InitiateMWST& other)
{
    if (this==&other) return *this;
    ::cPacket::operator=(other);
    copy(other);
    return *this;
}

void InitiateMWST::copy(const InitiateMWST& other)
{
    this->fragmentId_var = other.fragmentId_var;
    this->sender_var = other.sender_var;
}

void InitiateMWST::parsimPack(cCommBuffer *b)
{
    ::cPacket::parsimPack(b);
    doPacking(b,this->fragmentId_var);
    doPacking(b,this->sender_var);
}

void InitiateMWST::parsimUnpack(cCommBuffer *b)
{
    ::cPacket::parsimUnpack(b);
    doUnpacking(b,this->fragmentId_var);
    doUnpacking(b,this->sender_var);
}

const char * InitiateMWST::getFragmentId() const
{
    return fragmentId_var.c_str();
}

void InitiateMWST::setFragmentId(const char * fragmentId)
{
    this->fragmentId_var = fragmentId;
}

const char * InitiateMWST::getSender() const
{
    return sender_var.c_str();
}

void InitiateMWST::setSender(const char * sender)
{
    this->sender_var = sender;
}

class InitiateMWSTDescriptor : public cClassDescriptor
{
  public:
    InitiateMWSTDescriptor();
    virtual ~InitiateMWSTDescriptor();

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

Register_ClassDescriptor(InitiateMWSTDescriptor);

InitiateMWSTDescriptor::InitiateMWSTDescriptor() : cClassDescriptor("inet::ewma::InitiateMWST", "cPacket")
{
}

InitiateMWSTDescriptor::~InitiateMWSTDescriptor()
{
}

bool InitiateMWSTDescriptor::doesSupport(cObject *obj) const
{
    return dynamic_cast<InitiateMWST *>(obj)!=NULL;
}

const char *InitiateMWSTDescriptor::getProperty(const char *propertyname) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    return basedesc ? basedesc->getProperty(propertyname) : NULL;
}

int InitiateMWSTDescriptor::getFieldCount(void *object) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    return basedesc ? 2+basedesc->getFieldCount(object) : 2;
}

unsigned int InitiateMWSTDescriptor::getFieldTypeFlags(void *object, int field) const
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

const char *InitiateMWSTDescriptor::getFieldName(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldName(object, field);
        field -= basedesc->getFieldCount(object);
    }
    static const char *fieldNames[] = {
        "fragmentId",
        "sender",
    };
    return (field>=0 && field<2) ? fieldNames[field] : NULL;
}

int InitiateMWSTDescriptor::findField(void *object, const char *fieldName) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    int base = basedesc ? basedesc->getFieldCount(object) : 0;
    if (fieldName[0]=='f' && strcmp(fieldName, "fragmentId")==0) return base+0;
    if (fieldName[0]=='s' && strcmp(fieldName, "sender")==0) return base+1;
    return basedesc ? basedesc->findField(object, fieldName) : -1;
}

const char *InitiateMWSTDescriptor::getFieldTypeString(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldTypeString(object, field);
        field -= basedesc->getFieldCount(object);
    }
    static const char *fieldTypeStrings[] = {
        "string",
        "string",
    };
    return (field>=0 && field<2) ? fieldTypeStrings[field] : NULL;
}

const char *InitiateMWSTDescriptor::getFieldProperty(void *object, int field, const char *propertyname) const
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

int InitiateMWSTDescriptor::getArraySize(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getArraySize(object, field);
        field -= basedesc->getFieldCount(object);
    }
    InitiateMWST *pp = (InitiateMWST *)object; (void)pp;
    switch (field) {
        default: return 0;
    }
}

std::string InitiateMWSTDescriptor::getFieldAsString(void *object, int field, int i) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldAsString(object,field,i);
        field -= basedesc->getFieldCount(object);
    }
    InitiateMWST *pp = (InitiateMWST *)object; (void)pp;
    switch (field) {
        case 0: return oppstring2string(pp->getFragmentId());
        case 1: return oppstring2string(pp->getSender());
        default: return "";
    }
}

bool InitiateMWSTDescriptor::setFieldAsString(void *object, int field, int i, const char *value) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->setFieldAsString(object,field,i,value);
        field -= basedesc->getFieldCount(object);
    }
    InitiateMWST *pp = (InitiateMWST *)object; (void)pp;
    switch (field) {
        case 0: pp->setFragmentId((value)); return true;
        case 1: pp->setSender((value)); return true;
        default: return false;
    }
}

const char *InitiateMWSTDescriptor::getFieldStructName(void *object, int field) const
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

void *InitiateMWSTDescriptor::getFieldStructPointer(void *object, int field, int i) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldStructPointer(object, field, i);
        field -= basedesc->getFieldCount(object);
    }
    InitiateMWST *pp = (InitiateMWST *)object; (void)pp;
    switch (field) {
        default: return NULL;
    }
}

Register_Class(TestMWST);

TestMWST::TestMWST(const char *name, int kind) : ::cPacket(name,kind)
{
    this->fragmentId_var = 0;
    this->sender_var = 0;
}

TestMWST::TestMWST(const TestMWST& other) : ::cPacket(other)
{
    copy(other);
}

TestMWST::~TestMWST()
{
}

TestMWST& TestMWST::operator=(const TestMWST& other)
{
    if (this==&other) return *this;
    ::cPacket::operator=(other);
    copy(other);
    return *this;
}

void TestMWST::copy(const TestMWST& other)
{
    this->fragmentId_var = other.fragmentId_var;
    this->sender_var = other.sender_var;
}

void TestMWST::parsimPack(cCommBuffer *b)
{
    ::cPacket::parsimPack(b);
    doPacking(b,this->fragmentId_var);
    doPacking(b,this->sender_var);
}

void TestMWST::parsimUnpack(cCommBuffer *b)
{
    ::cPacket::parsimUnpack(b);
    doUnpacking(b,this->fragmentId_var);
    doUnpacking(b,this->sender_var);
}

const char * TestMWST::getFragmentId() const
{
    return fragmentId_var.c_str();
}

void TestMWST::setFragmentId(const char * fragmentId)
{
    this->fragmentId_var = fragmentId;
}

const char * TestMWST::getSender() const
{
    return sender_var.c_str();
}

void TestMWST::setSender(const char * sender)
{
    this->sender_var = sender;
}

class TestMWSTDescriptor : public cClassDescriptor
{
  public:
    TestMWSTDescriptor();
    virtual ~TestMWSTDescriptor();

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

Register_ClassDescriptor(TestMWSTDescriptor);

TestMWSTDescriptor::TestMWSTDescriptor() : cClassDescriptor("inet::ewma::TestMWST", "cPacket")
{
}

TestMWSTDescriptor::~TestMWSTDescriptor()
{
}

bool TestMWSTDescriptor::doesSupport(cObject *obj) const
{
    return dynamic_cast<TestMWST *>(obj)!=NULL;
}

const char *TestMWSTDescriptor::getProperty(const char *propertyname) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    return basedesc ? basedesc->getProperty(propertyname) : NULL;
}

int TestMWSTDescriptor::getFieldCount(void *object) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    return basedesc ? 2+basedesc->getFieldCount(object) : 2;
}

unsigned int TestMWSTDescriptor::getFieldTypeFlags(void *object, int field) const
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

const char *TestMWSTDescriptor::getFieldName(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldName(object, field);
        field -= basedesc->getFieldCount(object);
    }
    static const char *fieldNames[] = {
        "fragmentId",
        "sender",
    };
    return (field>=0 && field<2) ? fieldNames[field] : NULL;
}

int TestMWSTDescriptor::findField(void *object, const char *fieldName) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    int base = basedesc ? basedesc->getFieldCount(object) : 0;
    if (fieldName[0]=='f' && strcmp(fieldName, "fragmentId")==0) return base+0;
    if (fieldName[0]=='s' && strcmp(fieldName, "sender")==0) return base+1;
    return basedesc ? basedesc->findField(object, fieldName) : -1;
}

const char *TestMWSTDescriptor::getFieldTypeString(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldTypeString(object, field);
        field -= basedesc->getFieldCount(object);
    }
    static const char *fieldTypeStrings[] = {
        "string",
        "string",
    };
    return (field>=0 && field<2) ? fieldTypeStrings[field] : NULL;
}

const char *TestMWSTDescriptor::getFieldProperty(void *object, int field, const char *propertyname) const
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

int TestMWSTDescriptor::getArraySize(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getArraySize(object, field);
        field -= basedesc->getFieldCount(object);
    }
    TestMWST *pp = (TestMWST *)object; (void)pp;
    switch (field) {
        default: return 0;
    }
}

std::string TestMWSTDescriptor::getFieldAsString(void *object, int field, int i) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldAsString(object,field,i);
        field -= basedesc->getFieldCount(object);
    }
    TestMWST *pp = (TestMWST *)object; (void)pp;
    switch (field) {
        case 0: return oppstring2string(pp->getFragmentId());
        case 1: return oppstring2string(pp->getSender());
        default: return "";
    }
}

bool TestMWSTDescriptor::setFieldAsString(void *object, int field, int i, const char *value) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->setFieldAsString(object,field,i,value);
        field -= basedesc->getFieldCount(object);
    }
    TestMWST *pp = (TestMWST *)object; (void)pp;
    switch (field) {
        case 0: pp->setFragmentId((value)); return true;
        case 1: pp->setSender((value)); return true;
        default: return false;
    }
}

const char *TestMWSTDescriptor::getFieldStructName(void *object, int field) const
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

void *TestMWSTDescriptor::getFieldStructPointer(void *object, int field, int i) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldStructPointer(object, field, i);
        field -= basedesc->getFieldCount(object);
    }
    TestMWST *pp = (TestMWST *)object; (void)pp;
    switch (field) {
        default: return NULL;
    }
}

Register_Class(AcceptMWST);

AcceptMWST::AcceptMWST(const char *name, int kind) : ::cPacket(name,kind)
{
    this->sender_var = 0;
}

AcceptMWST::AcceptMWST(const AcceptMWST& other) : ::cPacket(other)
{
    copy(other);
}

AcceptMWST::~AcceptMWST()
{
}

AcceptMWST& AcceptMWST::operator=(const AcceptMWST& other)
{
    if (this==&other) return *this;
    ::cPacket::operator=(other);
    copy(other);
    return *this;
}

void AcceptMWST::copy(const AcceptMWST& other)
{
    this->sender_var = other.sender_var;
}

void AcceptMWST::parsimPack(cCommBuffer *b)
{
    ::cPacket::parsimPack(b);
    doPacking(b,this->sender_var);
}

void AcceptMWST::parsimUnpack(cCommBuffer *b)
{
    ::cPacket::parsimUnpack(b);
    doUnpacking(b,this->sender_var);
}

const char * AcceptMWST::getSender() const
{
    return sender_var.c_str();
}

void AcceptMWST::setSender(const char * sender)
{
    this->sender_var = sender;
}

class AcceptMWSTDescriptor : public cClassDescriptor
{
  public:
    AcceptMWSTDescriptor();
    virtual ~AcceptMWSTDescriptor();

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

Register_ClassDescriptor(AcceptMWSTDescriptor);

AcceptMWSTDescriptor::AcceptMWSTDescriptor() : cClassDescriptor("inet::ewma::AcceptMWST", "cPacket")
{
}

AcceptMWSTDescriptor::~AcceptMWSTDescriptor()
{
}

bool AcceptMWSTDescriptor::doesSupport(cObject *obj) const
{
    return dynamic_cast<AcceptMWST *>(obj)!=NULL;
}

const char *AcceptMWSTDescriptor::getProperty(const char *propertyname) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    return basedesc ? basedesc->getProperty(propertyname) : NULL;
}

int AcceptMWSTDescriptor::getFieldCount(void *object) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    return basedesc ? 1+basedesc->getFieldCount(object) : 1;
}

unsigned int AcceptMWSTDescriptor::getFieldTypeFlags(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldTypeFlags(object, field);
        field -= basedesc->getFieldCount(object);
    }
    static unsigned int fieldTypeFlags[] = {
        FD_ISEDITABLE,
    };
    return (field>=0 && field<1) ? fieldTypeFlags[field] : 0;
}

const char *AcceptMWSTDescriptor::getFieldName(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldName(object, field);
        field -= basedesc->getFieldCount(object);
    }
    static const char *fieldNames[] = {
        "sender",
    };
    return (field>=0 && field<1) ? fieldNames[field] : NULL;
}

int AcceptMWSTDescriptor::findField(void *object, const char *fieldName) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    int base = basedesc ? basedesc->getFieldCount(object) : 0;
    if (fieldName[0]=='s' && strcmp(fieldName, "sender")==0) return base+0;
    return basedesc ? basedesc->findField(object, fieldName) : -1;
}

const char *AcceptMWSTDescriptor::getFieldTypeString(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldTypeString(object, field);
        field -= basedesc->getFieldCount(object);
    }
    static const char *fieldTypeStrings[] = {
        "string",
    };
    return (field>=0 && field<1) ? fieldTypeStrings[field] : NULL;
}

const char *AcceptMWSTDescriptor::getFieldProperty(void *object, int field, const char *propertyname) const
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

int AcceptMWSTDescriptor::getArraySize(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getArraySize(object, field);
        field -= basedesc->getFieldCount(object);
    }
    AcceptMWST *pp = (AcceptMWST *)object; (void)pp;
    switch (field) {
        default: return 0;
    }
}

std::string AcceptMWSTDescriptor::getFieldAsString(void *object, int field, int i) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldAsString(object,field,i);
        field -= basedesc->getFieldCount(object);
    }
    AcceptMWST *pp = (AcceptMWST *)object; (void)pp;
    switch (field) {
        case 0: return oppstring2string(pp->getSender());
        default: return "";
    }
}

bool AcceptMWSTDescriptor::setFieldAsString(void *object, int field, int i, const char *value) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->setFieldAsString(object,field,i,value);
        field -= basedesc->getFieldCount(object);
    }
    AcceptMWST *pp = (AcceptMWST *)object; (void)pp;
    switch (field) {
        case 0: pp->setSender((value)); return true;
        default: return false;
    }
}

const char *AcceptMWSTDescriptor::getFieldStructName(void *object, int field) const
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

void *AcceptMWSTDescriptor::getFieldStructPointer(void *object, int field, int i) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldStructPointer(object, field, i);
        field -= basedesc->getFieldCount(object);
    }
    AcceptMWST *pp = (AcceptMWST *)object; (void)pp;
    switch (field) {
        default: return NULL;
    }
}

Register_Class(RejectMWST);

RejectMWST::RejectMWST(const char *name, int kind) : ::cPacket(name,kind)
{
    this->sender_var = 0;
}

RejectMWST::RejectMWST(const RejectMWST& other) : ::cPacket(other)
{
    copy(other);
}

RejectMWST::~RejectMWST()
{
}

RejectMWST& RejectMWST::operator=(const RejectMWST& other)
{
    if (this==&other) return *this;
    ::cPacket::operator=(other);
    copy(other);
    return *this;
}

void RejectMWST::copy(const RejectMWST& other)
{
    this->sender_var = other.sender_var;
}

void RejectMWST::parsimPack(cCommBuffer *b)
{
    ::cPacket::parsimPack(b);
    doPacking(b,this->sender_var);
}

void RejectMWST::parsimUnpack(cCommBuffer *b)
{
    ::cPacket::parsimUnpack(b);
    doUnpacking(b,this->sender_var);
}

const char * RejectMWST::getSender() const
{
    return sender_var.c_str();
}

void RejectMWST::setSender(const char * sender)
{
    this->sender_var = sender;
}

class RejectMWSTDescriptor : public cClassDescriptor
{
  public:
    RejectMWSTDescriptor();
    virtual ~RejectMWSTDescriptor();

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

Register_ClassDescriptor(RejectMWSTDescriptor);

RejectMWSTDescriptor::RejectMWSTDescriptor() : cClassDescriptor("inet::ewma::RejectMWST", "cPacket")
{
}

RejectMWSTDescriptor::~RejectMWSTDescriptor()
{
}

bool RejectMWSTDescriptor::doesSupport(cObject *obj) const
{
    return dynamic_cast<RejectMWST *>(obj)!=NULL;
}

const char *RejectMWSTDescriptor::getProperty(const char *propertyname) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    return basedesc ? basedesc->getProperty(propertyname) : NULL;
}

int RejectMWSTDescriptor::getFieldCount(void *object) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    return basedesc ? 1+basedesc->getFieldCount(object) : 1;
}

unsigned int RejectMWSTDescriptor::getFieldTypeFlags(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldTypeFlags(object, field);
        field -= basedesc->getFieldCount(object);
    }
    static unsigned int fieldTypeFlags[] = {
        FD_ISEDITABLE,
    };
    return (field>=0 && field<1) ? fieldTypeFlags[field] : 0;
}

const char *RejectMWSTDescriptor::getFieldName(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldName(object, field);
        field -= basedesc->getFieldCount(object);
    }
    static const char *fieldNames[] = {
        "sender",
    };
    return (field>=0 && field<1) ? fieldNames[field] : NULL;
}

int RejectMWSTDescriptor::findField(void *object, const char *fieldName) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    int base = basedesc ? basedesc->getFieldCount(object) : 0;
    if (fieldName[0]=='s' && strcmp(fieldName, "sender")==0) return base+0;
    return basedesc ? basedesc->findField(object, fieldName) : -1;
}

const char *RejectMWSTDescriptor::getFieldTypeString(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldTypeString(object, field);
        field -= basedesc->getFieldCount(object);
    }
    static const char *fieldTypeStrings[] = {
        "string",
    };
    return (field>=0 && field<1) ? fieldTypeStrings[field] : NULL;
}

const char *RejectMWSTDescriptor::getFieldProperty(void *object, int field, const char *propertyname) const
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

int RejectMWSTDescriptor::getArraySize(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getArraySize(object, field);
        field -= basedesc->getFieldCount(object);
    }
    RejectMWST *pp = (RejectMWST *)object; (void)pp;
    switch (field) {
        default: return 0;
    }
}

std::string RejectMWSTDescriptor::getFieldAsString(void *object, int field, int i) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldAsString(object,field,i);
        field -= basedesc->getFieldCount(object);
    }
    RejectMWST *pp = (RejectMWST *)object; (void)pp;
    switch (field) {
        case 0: return oppstring2string(pp->getSender());
        default: return "";
    }
}

bool RejectMWSTDescriptor::setFieldAsString(void *object, int field, int i, const char *value) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->setFieldAsString(object,field,i,value);
        field -= basedesc->getFieldCount(object);
    }
    RejectMWST *pp = (RejectMWST *)object; (void)pp;
    switch (field) {
        case 0: pp->setSender((value)); return true;
        default: return false;
    }
}

const char *RejectMWSTDescriptor::getFieldStructName(void *object, int field) const
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

void *RejectMWSTDescriptor::getFieldStructPointer(void *object, int field, int i) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldStructPointer(object, field, i);
        field -= basedesc->getFieldCount(object);
    }
    RejectMWST *pp = (RejectMWST *)object; (void)pp;
    switch (field) {
        default: return NULL;
    }
}

Register_Class(ReportMWST);

ReportMWST::ReportMWST(const char *name, int kind) : ::cPacket(name,kind)
{
    this->weight_var = 0;
    this->sender_var = 0;
}

ReportMWST::ReportMWST(const ReportMWST& other) : ::cPacket(other)
{
    copy(other);
}

ReportMWST::~ReportMWST()
{
}

ReportMWST& ReportMWST::operator=(const ReportMWST& other)
{
    if (this==&other) return *this;
    ::cPacket::operator=(other);
    copy(other);
    return *this;
}

void ReportMWST::copy(const ReportMWST& other)
{
    this->weight_var = other.weight_var;
    this->sender_var = other.sender_var;
}

void ReportMWST::parsimPack(cCommBuffer *b)
{
    ::cPacket::parsimPack(b);
    doPacking(b,this->weight_var);
    doPacking(b,this->sender_var);
}

void ReportMWST::parsimUnpack(cCommBuffer *b)
{
    ::cPacket::parsimUnpack(b);
    doUnpacking(b,this->weight_var);
    doUnpacking(b,this->sender_var);
}

double ReportMWST::getWeight() const
{
    return weight_var;
}

void ReportMWST::setWeight(double weight)
{
    this->weight_var = weight;
}

const char * ReportMWST::getSender() const
{
    return sender_var.c_str();
}

void ReportMWST::setSender(const char * sender)
{
    this->sender_var = sender;
}

class ReportMWSTDescriptor : public cClassDescriptor
{
  public:
    ReportMWSTDescriptor();
    virtual ~ReportMWSTDescriptor();

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

Register_ClassDescriptor(ReportMWSTDescriptor);

ReportMWSTDescriptor::ReportMWSTDescriptor() : cClassDescriptor("inet::ewma::ReportMWST", "cPacket")
{
}

ReportMWSTDescriptor::~ReportMWSTDescriptor()
{
}

bool ReportMWSTDescriptor::doesSupport(cObject *obj) const
{
    return dynamic_cast<ReportMWST *>(obj)!=NULL;
}

const char *ReportMWSTDescriptor::getProperty(const char *propertyname) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    return basedesc ? basedesc->getProperty(propertyname) : NULL;
}

int ReportMWSTDescriptor::getFieldCount(void *object) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    return basedesc ? 2+basedesc->getFieldCount(object) : 2;
}

unsigned int ReportMWSTDescriptor::getFieldTypeFlags(void *object, int field) const
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

const char *ReportMWSTDescriptor::getFieldName(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldName(object, field);
        field -= basedesc->getFieldCount(object);
    }
    static const char *fieldNames[] = {
        "weight",
        "sender",
    };
    return (field>=0 && field<2) ? fieldNames[field] : NULL;
}

int ReportMWSTDescriptor::findField(void *object, const char *fieldName) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    int base = basedesc ? basedesc->getFieldCount(object) : 0;
    if (fieldName[0]=='w' && strcmp(fieldName, "weight")==0) return base+0;
    if (fieldName[0]=='s' && strcmp(fieldName, "sender")==0) return base+1;
    return basedesc ? basedesc->findField(object, fieldName) : -1;
}

const char *ReportMWSTDescriptor::getFieldTypeString(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldTypeString(object, field);
        field -= basedesc->getFieldCount(object);
    }
    static const char *fieldTypeStrings[] = {
        "double",
        "string",
    };
    return (field>=0 && field<2) ? fieldTypeStrings[field] : NULL;
}

const char *ReportMWSTDescriptor::getFieldProperty(void *object, int field, const char *propertyname) const
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

int ReportMWSTDescriptor::getArraySize(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getArraySize(object, field);
        field -= basedesc->getFieldCount(object);
    }
    ReportMWST *pp = (ReportMWST *)object; (void)pp;
    switch (field) {
        default: return 0;
    }
}

std::string ReportMWSTDescriptor::getFieldAsString(void *object, int field, int i) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldAsString(object,field,i);
        field -= basedesc->getFieldCount(object);
    }
    ReportMWST *pp = (ReportMWST *)object; (void)pp;
    switch (field) {
        case 0: return double2string(pp->getWeight());
        case 1: return oppstring2string(pp->getSender());
        default: return "";
    }
}

bool ReportMWSTDescriptor::setFieldAsString(void *object, int field, int i, const char *value) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->setFieldAsString(object,field,i,value);
        field -= basedesc->getFieldCount(object);
    }
    ReportMWST *pp = (ReportMWST *)object; (void)pp;
    switch (field) {
        case 0: pp->setWeight(string2double(value)); return true;
        case 1: pp->setSender((value)); return true;
        default: return false;
    }
}

const char *ReportMWSTDescriptor::getFieldStructName(void *object, int field) const
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

void *ReportMWSTDescriptor::getFieldStructPointer(void *object, int field, int i) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldStructPointer(object, field, i);
        field -= basedesc->getFieldCount(object);
    }
    ReportMWST *pp = (ReportMWST *)object; (void)pp;
    switch (field) {
        default: return NULL;
    }
}

Register_Class(ChangeRootMWST);

ChangeRootMWST::ChangeRootMWST(const char *name, int kind) : ::cPacket(name,kind)
{
    this->sender_var = 0;
}

ChangeRootMWST::ChangeRootMWST(const ChangeRootMWST& other) : ::cPacket(other)
{
    copy(other);
}

ChangeRootMWST::~ChangeRootMWST()
{
}

ChangeRootMWST& ChangeRootMWST::operator=(const ChangeRootMWST& other)
{
    if (this==&other) return *this;
    ::cPacket::operator=(other);
    copy(other);
    return *this;
}

void ChangeRootMWST::copy(const ChangeRootMWST& other)
{
    this->sender_var = other.sender_var;
}

void ChangeRootMWST::parsimPack(cCommBuffer *b)
{
    ::cPacket::parsimPack(b);
    doPacking(b,this->sender_var);
}

void ChangeRootMWST::parsimUnpack(cCommBuffer *b)
{
    ::cPacket::parsimUnpack(b);
    doUnpacking(b,this->sender_var);
}

const char * ChangeRootMWST::getSender() const
{
    return sender_var.c_str();
}

void ChangeRootMWST::setSender(const char * sender)
{
    this->sender_var = sender;
}

class ChangeRootMWSTDescriptor : public cClassDescriptor
{
  public:
    ChangeRootMWSTDescriptor();
    virtual ~ChangeRootMWSTDescriptor();

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

Register_ClassDescriptor(ChangeRootMWSTDescriptor);

ChangeRootMWSTDescriptor::ChangeRootMWSTDescriptor() : cClassDescriptor("inet::ewma::ChangeRootMWST", "cPacket")
{
}

ChangeRootMWSTDescriptor::~ChangeRootMWSTDescriptor()
{
}

bool ChangeRootMWSTDescriptor::doesSupport(cObject *obj) const
{
    return dynamic_cast<ChangeRootMWST *>(obj)!=NULL;
}

const char *ChangeRootMWSTDescriptor::getProperty(const char *propertyname) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    return basedesc ? basedesc->getProperty(propertyname) : NULL;
}

int ChangeRootMWSTDescriptor::getFieldCount(void *object) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    return basedesc ? 1+basedesc->getFieldCount(object) : 1;
}

unsigned int ChangeRootMWSTDescriptor::getFieldTypeFlags(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldTypeFlags(object, field);
        field -= basedesc->getFieldCount(object);
    }
    static unsigned int fieldTypeFlags[] = {
        FD_ISEDITABLE,
    };
    return (field>=0 && field<1) ? fieldTypeFlags[field] : 0;
}

const char *ChangeRootMWSTDescriptor::getFieldName(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldName(object, field);
        field -= basedesc->getFieldCount(object);
    }
    static const char *fieldNames[] = {
        "sender",
    };
    return (field>=0 && field<1) ? fieldNames[field] : NULL;
}

int ChangeRootMWSTDescriptor::findField(void *object, const char *fieldName) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    int base = basedesc ? basedesc->getFieldCount(object) : 0;
    if (fieldName[0]=='s' && strcmp(fieldName, "sender")==0) return base+0;
    return basedesc ? basedesc->findField(object, fieldName) : -1;
}

const char *ChangeRootMWSTDescriptor::getFieldTypeString(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldTypeString(object, field);
        field -= basedesc->getFieldCount(object);
    }
    static const char *fieldTypeStrings[] = {
        "string",
    };
    return (field>=0 && field<1) ? fieldTypeStrings[field] : NULL;
}

const char *ChangeRootMWSTDescriptor::getFieldProperty(void *object, int field, const char *propertyname) const
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

int ChangeRootMWSTDescriptor::getArraySize(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getArraySize(object, field);
        field -= basedesc->getFieldCount(object);
    }
    ChangeRootMWST *pp = (ChangeRootMWST *)object; (void)pp;
    switch (field) {
        default: return 0;
    }
}

std::string ChangeRootMWSTDescriptor::getFieldAsString(void *object, int field, int i) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldAsString(object,field,i);
        field -= basedesc->getFieldCount(object);
    }
    ChangeRootMWST *pp = (ChangeRootMWST *)object; (void)pp;
    switch (field) {
        case 0: return oppstring2string(pp->getSender());
        default: return "";
    }
}

bool ChangeRootMWSTDescriptor::setFieldAsString(void *object, int field, int i, const char *value) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->setFieldAsString(object,field,i,value);
        field -= basedesc->getFieldCount(object);
    }
    ChangeRootMWST *pp = (ChangeRootMWST *)object; (void)pp;
    switch (field) {
        case 0: pp->setSender((value)); return true;
        default: return false;
    }
}

const char *ChangeRootMWSTDescriptor::getFieldStructName(void *object, int field) const
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

void *ChangeRootMWSTDescriptor::getFieldStructPointer(void *object, int field, int i) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldStructPointer(object, field, i);
        field -= basedesc->getFieldCount(object);
    }
    ChangeRootMWST *pp = (ChangeRootMWST *)object; (void)pp;
    switch (field) {
        default: return NULL;
    }
}

Register_Class(InNewFragment);

InNewFragment::InNewFragment(const char *name, int kind) : ::cPacket(name,kind)
{
    this->sender_var = 0;
    this->fragmentId_var = 0;
}

InNewFragment::InNewFragment(const InNewFragment& other) : ::cPacket(other)
{
    copy(other);
}

InNewFragment::~InNewFragment()
{
}

InNewFragment& InNewFragment::operator=(const InNewFragment& other)
{
    if (this==&other) return *this;
    ::cPacket::operator=(other);
    copy(other);
    return *this;
}

void InNewFragment::copy(const InNewFragment& other)
{
    this->sender_var = other.sender_var;
    this->fragmentId_var = other.fragmentId_var;
}

void InNewFragment::parsimPack(cCommBuffer *b)
{
    ::cPacket::parsimPack(b);
    doPacking(b,this->sender_var);
    doPacking(b,this->fragmentId_var);
}

void InNewFragment::parsimUnpack(cCommBuffer *b)
{
    ::cPacket::parsimUnpack(b);
    doUnpacking(b,this->sender_var);
    doUnpacking(b,this->fragmentId_var);
}

const char * InNewFragment::getSender() const
{
    return sender_var.c_str();
}

void InNewFragment::setSender(const char * sender)
{
    this->sender_var = sender;
}

const char * InNewFragment::getFragmentId() const
{
    return fragmentId_var.c_str();
}

void InNewFragment::setFragmentId(const char * fragmentId)
{
    this->fragmentId_var = fragmentId;
}

class InNewFragmentDescriptor : public cClassDescriptor
{
  public:
    InNewFragmentDescriptor();
    virtual ~InNewFragmentDescriptor();

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

Register_ClassDescriptor(InNewFragmentDescriptor);

InNewFragmentDescriptor::InNewFragmentDescriptor() : cClassDescriptor("inet::ewma::InNewFragment", "cPacket")
{
}

InNewFragmentDescriptor::~InNewFragmentDescriptor()
{
}

bool InNewFragmentDescriptor::doesSupport(cObject *obj) const
{
    return dynamic_cast<InNewFragment *>(obj)!=NULL;
}

const char *InNewFragmentDescriptor::getProperty(const char *propertyname) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    return basedesc ? basedesc->getProperty(propertyname) : NULL;
}

int InNewFragmentDescriptor::getFieldCount(void *object) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    return basedesc ? 2+basedesc->getFieldCount(object) : 2;
}

unsigned int InNewFragmentDescriptor::getFieldTypeFlags(void *object, int field) const
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

const char *InNewFragmentDescriptor::getFieldName(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldName(object, field);
        field -= basedesc->getFieldCount(object);
    }
    static const char *fieldNames[] = {
        "sender",
        "fragmentId",
    };
    return (field>=0 && field<2) ? fieldNames[field] : NULL;
}

int InNewFragmentDescriptor::findField(void *object, const char *fieldName) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    int base = basedesc ? basedesc->getFieldCount(object) : 0;
    if (fieldName[0]=='s' && strcmp(fieldName, "sender")==0) return base+0;
    if (fieldName[0]=='f' && strcmp(fieldName, "fragmentId")==0) return base+1;
    return basedesc ? basedesc->findField(object, fieldName) : -1;
}

const char *InNewFragmentDescriptor::getFieldTypeString(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldTypeString(object, field);
        field -= basedesc->getFieldCount(object);
    }
    static const char *fieldTypeStrings[] = {
        "string",
        "string",
    };
    return (field>=0 && field<2) ? fieldTypeStrings[field] : NULL;
}

const char *InNewFragmentDescriptor::getFieldProperty(void *object, int field, const char *propertyname) const
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

int InNewFragmentDescriptor::getArraySize(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getArraySize(object, field);
        field -= basedesc->getFieldCount(object);
    }
    InNewFragment *pp = (InNewFragment *)object; (void)pp;
    switch (field) {
        default: return 0;
    }
}

std::string InNewFragmentDescriptor::getFieldAsString(void *object, int field, int i) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldAsString(object,field,i);
        field -= basedesc->getFieldCount(object);
    }
    InNewFragment *pp = (InNewFragment *)object; (void)pp;
    switch (field) {
        case 0: return oppstring2string(pp->getSender());
        case 1: return oppstring2string(pp->getFragmentId());
        default: return "";
    }
}

bool InNewFragmentDescriptor::setFieldAsString(void *object, int field, int i, const char *value) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->setFieldAsString(object,field,i,value);
        field -= basedesc->getFieldCount(object);
    }
    InNewFragment *pp = (InNewFragment *)object; (void)pp;
    switch (field) {
        case 0: pp->setSender((value)); return true;
        case 1: pp->setFragmentId((value)); return true;
        default: return false;
    }
}

const char *InNewFragmentDescriptor::getFieldStructName(void *object, int field) const
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

void *InNewFragmentDescriptor::getFieldStructPointer(void *object, int field, int i) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldStructPointer(object, field, i);
        field -= basedesc->getFieldCount(object);
    }
    InNewFragment *pp = (InNewFragment *)object; (void)pp;
    switch (field) {
        default: return NULL;
    }
}

} // namespace ewma
} // namespace inet

