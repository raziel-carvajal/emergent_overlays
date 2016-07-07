//
// Generated file, do not edit! Created by nedtool 4.6 from mwst2/MWSTMsgs.msg.
//

// Disable warnings about unused variables, empty switch stmts, etc:
#ifdef _MSC_VER
#  pragma warning(disable:4101)
#  pragma warning(disable:4065)
#endif

#include <iostream>
#include <sstream>
#include "MWSTMsgs_m.h"

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

Register_Class(HelloMWST);

HelloMWST::HelloMWST(const char *name, int kind) : ::cPacket(name,kind)
{
    this->sender_var = 0;
    this->x_var = 0;
    this->y_var = 0;
}

HelloMWST::HelloMWST(const HelloMWST& other) : ::cPacket(other)
{
    copy(other);
}

HelloMWST::~HelloMWST()
{
}

HelloMWST& HelloMWST::operator=(const HelloMWST& other)
{
    if (this==&other) return *this;
    ::cPacket::operator=(other);
    copy(other);
    return *this;
}

void HelloMWST::copy(const HelloMWST& other)
{
    this->sender_var = other.sender_var;
    this->x_var = other.x_var;
    this->y_var = other.y_var;
}

void HelloMWST::parsimPack(cCommBuffer *b)
{
    ::cPacket::parsimPack(b);
    doPacking(b,this->sender_var);
    doPacking(b,this->x_var);
    doPacking(b,this->y_var);
}

void HelloMWST::parsimUnpack(cCommBuffer *b)
{
    ::cPacket::parsimUnpack(b);
    doUnpacking(b,this->sender_var);
    doUnpacking(b,this->x_var);
    doUnpacking(b,this->y_var);
}

const char * HelloMWST::getSender() const
{
    return sender_var.c_str();
}

void HelloMWST::setSender(const char * sender)
{
    this->sender_var = sender;
}

double HelloMWST::getX() const
{
    return x_var;
}

void HelloMWST::setX(double x)
{
    this->x_var = x;
}

double HelloMWST::getY() const
{
    return y_var;
}

void HelloMWST::setY(double y)
{
    this->y_var = y;
}

class HelloMWSTDescriptor : public cClassDescriptor
{
  public:
    HelloMWSTDescriptor();
    virtual ~HelloMWSTDescriptor();

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

Register_ClassDescriptor(HelloMWSTDescriptor);

HelloMWSTDescriptor::HelloMWSTDescriptor() : cClassDescriptor("inet::HelloMWST", "cPacket")
{
}

HelloMWSTDescriptor::~HelloMWSTDescriptor()
{
}

bool HelloMWSTDescriptor::doesSupport(cObject *obj) const
{
    return dynamic_cast<HelloMWST *>(obj)!=NULL;
}

const char *HelloMWSTDescriptor::getProperty(const char *propertyname) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    return basedesc ? basedesc->getProperty(propertyname) : NULL;
}

int HelloMWSTDescriptor::getFieldCount(void *object) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    return basedesc ? 3+basedesc->getFieldCount(object) : 3;
}

unsigned int HelloMWSTDescriptor::getFieldTypeFlags(void *object, int field) const
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
    };
    return (field>=0 && field<3) ? fieldTypeFlags[field] : 0;
}

const char *HelloMWSTDescriptor::getFieldName(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldName(object, field);
        field -= basedesc->getFieldCount(object);
    }
    static const char *fieldNames[] = {
        "sender",
        "x",
        "y",
    };
    return (field>=0 && field<3) ? fieldNames[field] : NULL;
}

int HelloMWSTDescriptor::findField(void *object, const char *fieldName) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    int base = basedesc ? basedesc->getFieldCount(object) : 0;
    if (fieldName[0]=='s' && strcmp(fieldName, "sender")==0) return base+0;
    if (fieldName[0]=='x' && strcmp(fieldName, "x")==0) return base+1;
    if (fieldName[0]=='y' && strcmp(fieldName, "y")==0) return base+2;
    return basedesc ? basedesc->findField(object, fieldName) : -1;
}

const char *HelloMWSTDescriptor::getFieldTypeString(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldTypeString(object, field);
        field -= basedesc->getFieldCount(object);
    }
    static const char *fieldTypeStrings[] = {
        "string",
        "double",
        "double",
    };
    return (field>=0 && field<3) ? fieldTypeStrings[field] : NULL;
}

const char *HelloMWSTDescriptor::getFieldProperty(void *object, int field, const char *propertyname) const
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

int HelloMWSTDescriptor::getArraySize(void *object, int field) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getArraySize(object, field);
        field -= basedesc->getFieldCount(object);
    }
    HelloMWST *pp = (HelloMWST *)object; (void)pp;
    switch (field) {
        default: return 0;
    }
}

std::string HelloMWSTDescriptor::getFieldAsString(void *object, int field, int i) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldAsString(object,field,i);
        field -= basedesc->getFieldCount(object);
    }
    HelloMWST *pp = (HelloMWST *)object; (void)pp;
    switch (field) {
        case 0: return oppstring2string(pp->getSender());
        case 1: return double2string(pp->getX());
        case 2: return double2string(pp->getY());
        default: return "";
    }
}

bool HelloMWSTDescriptor::setFieldAsString(void *object, int field, int i, const char *value) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->setFieldAsString(object,field,i,value);
        field -= basedesc->getFieldCount(object);
    }
    HelloMWST *pp = (HelloMWST *)object; (void)pp;
    switch (field) {
        case 0: pp->setSender((value)); return true;
        case 1: pp->setX(string2double(value)); return true;
        case 2: pp->setY(string2double(value)); return true;
        default: return false;
    }
}

const char *HelloMWSTDescriptor::getFieldStructName(void *object, int field) const
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

void *HelloMWSTDescriptor::getFieldStructPointer(void *object, int field, int i) const
{
    cClassDescriptor *basedesc = getBaseClassDescriptor();
    if (basedesc) {
        if (field < basedesc->getFieldCount(object))
            return basedesc->getFieldStructPointer(object, field, i);
        field -= basedesc->getFieldCount(object);
    }
    HelloMWST *pp = (HelloMWST *)object; (void)pp;
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

ConnectMWSTDescriptor::ConnectMWSTDescriptor() : cClassDescriptor("inet::ConnectMWST", "cPacket")
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

InitiateMWSTDescriptor::InitiateMWSTDescriptor() : cClassDescriptor("inet::InitiateMWST", "cPacket")
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

TestMWSTDescriptor::TestMWSTDescriptor() : cClassDescriptor("inet::TestMWST", "cPacket")
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

AcceptMWSTDescriptor::AcceptMWSTDescriptor() : cClassDescriptor("inet::AcceptMWST", "cPacket")
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

RejectMWSTDescriptor::RejectMWSTDescriptor() : cClassDescriptor("inet::RejectMWST", "cPacket")
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

ReportMWSTDescriptor::ReportMWSTDescriptor() : cClassDescriptor("inet::ReportMWST", "cPacket")
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

ChangeRootMWSTDescriptor::ChangeRootMWSTDescriptor() : cClassDescriptor("inet::ChangeRootMWST", "cPacket")
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

} // namespace inet

