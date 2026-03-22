@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZRAP_LEAVEREQ'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_RAP_LEAVEREQ
  as select from ZRAP_LEAVEREQ as LeaveRequest
{
  key request_uuid as RequestUUID,
  employee_id as EmployeeID,
  employee_name as EmployeeName,
  leave_type as LeaveType,
  start_date as StartDate,
  end_date as EndDate,
  total_days as TotalDays,
  reason as Reason,
  status as Status,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  created_at as CreatedAt,
  @Semantics.user.lastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt
}
