@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@Endusertext: {
  Label: '###GENERATED Core Data Service Entity'
}
@Objectmodel: {
  Sapobjectnodetype.Name: 'ZRAP_LEAVEREQ'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_RAP_LEAVEREQ
  provider contract TRANSACTIONAL_QUERY
  as projection on ZR_RAP_LEAVEREQ
  association [1..1] to ZR_RAP_LEAVEREQ as _BaseEntity on $projection.REQUESTUUID = _BaseEntity.REQUESTUUID
{
  key RequestUUID,
  EmployeeID,
  EmployeeName,
  LeaveType,
  StartDate,
  EndDate,
  TotalDays,
  Reason,
  Status,
  @Semantics: {
    User.Createdby: true
  }
  CreatedBy,
  CreatedAt,
  @Semantics: {
    User.Lastchangedby: true
  }
  LastChangedBy,
  @Semantics: {
    Systemdatetime.Lastchangedat: true
  }
  LastChangedAt,
  @Semantics: {
    Systemdatetime.Localinstancelastchangedat: true
  }
  LocalLastChangedAt,
  _BaseEntity
}
