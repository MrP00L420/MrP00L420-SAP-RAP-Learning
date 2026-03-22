CLASS LHC_ZR_RAP_LEAVEREQ DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR LeaveRequest
        RESULT result.

    METHODS Submit FOR MODIFY
      IMPORTING keys FOR ACTION LeaveRequest~Submit RESULT result.

    METHODS Approve FOR MODIFY
      IMPORTING keys FOR ACTION LeaveRequest~Approve RESULT result.

    METHODS Reject FOR MODIFY
      IMPORTING keys FOR ACTION LeaveRequest~Reject RESULT result.

    METHODS SetInitialValues FOR DETERMINE ON MODIFY
      IMPORTING keys FOR LeaveRequest~SetInitialValues.

    METHODS CalculateTotalDays FOR DETERMINE ON MODIFY
      IMPORTING keys FOR LeaveRequest~CalculateTotalDays.

    METHODS ValidateMandatoryFields FOR VALIDATE ON SAVE
      IMPORTING keys FOR LeaveRequest~ValidateMandatoryFields.

    METHODS ValidateDates FOR VALIDATE ON SAVE
      IMPORTING keys FOR LeaveRequest~ValidateDates.
ENDCLASS.

CLASS LHC_ZR_RAP_LEAVEREQ IMPLEMENTATION.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
  ENDMETHOD.

  METHOD Submit.

    DATA lv_now1  TYPE zr_leave_req-LastChangedAt.
    GET TIME STAMP FIELD lv_now1.

    DATA(lv_user) = cl_abap_context_info=>get_user_technical_name( ).


    READ ENTITIES OF zr_rap_leavereq IN LOCAL MODE
      ENTITY LeaveRequest
      FIELDS ( Status )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_requests).

    LOOP AT lt_requests INTO DATA(ls_request).

      IF ls_request-Status = 'APPROVED'.
        APPEND VALUE #( %tky = ls_request-%tky ) TO failed-LeaveRequest.
        APPEND VALUE #(
          %tky = ls_request-%tky
          %msg = new_message_with_text(
                    severity = if_abap_behv_message=>severity-error
                    text     = 'Approved request cannot be submitted again' )
        ) TO reported-LeaveRequest.
        CONTINUE.
      ENDIF.

      MODIFY ENTITIES OF zr_rap_leavereq IN LOCAL MODE
        ENTITY LeaveRequest
        UPDATE FIELDS ( Status LastChangedBy LastChangedAt LocalLastChangedAt )
        WITH VALUE #(
          ( %tky = ls_request-%tky
            Status             = 'SUBMITTED'
            LastChangedBy      = lv_user )
        "    LastChangedAt      = lv_now1
        "    LocalLastChangedAt = lv_now )
        ).

    ENDLOOP.

    READ ENTITIES OF zr_rap_leavereq IN LOCAL MODE
      ENTITY LeaveRequest
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).

    result = VALUE #( FOR ls_res IN lt_result
                      ( %tky = ls_res-%tky
                        %param = ls_res ) ).

  ENDMETHOD.

  METHOD Approve.

    DATA(lv_user) = cl_abap_context_info=>get_user_technical_name( ).
    DATA(lv_now)  = cl_abap_context_info=>get_system_time( ).

    READ ENTITIES OF zr_rap_leavereq IN LOCAL MODE
      ENTITY LeaveRequest
      FIELDS ( Status )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_requests).

    LOOP AT lt_requests INTO DATA(ls_request).

      IF ls_request-Status <> 'SUBMITTED'.
        APPEND VALUE #( %tky = ls_request-%tky ) TO failed-LeaveRequest.
        APPEND VALUE #(
          %tky = ls_request-%tky
          %msg = new_message_with_text(
                    severity = if_abap_behv_message=>severity-error
                    text     = 'Only submitted requests can be approved' )
        ) TO reported-LeaveRequest.
        CONTINUE.
      ENDIF.

      MODIFY ENTITIES OF zr_rap_leavereq IN LOCAL MODE
        ENTITY LeaveRequest
        UPDATE FIELDS ( Status LastChangedBy LastChangedAt LocalLastChangedAt )
        WITH VALUE #(
          ( %tky = ls_request-%tky
            Status             = 'APPROVED'
            LastChangedBy      = lv_user )
    ""      LastChangedAt      = lv_now
    ""        LocalLastChangedAt = lv_now )
        ).

    ENDLOOP.

    READ ENTITIES OF zr_rap_leavereq IN LOCAL MODE
      ENTITY LeaveRequest
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).

    result = VALUE #( FOR ls_res IN lt_result
                      ( %tky = ls_res-%tky
                        %param = ls_res ) ).

  ENDMETHOD.

  METHOD Reject.

    DATA(lv_user) = cl_abap_context_info=>get_user_technical_name( ).
    DATA(lv_now)  = cl_abap_context_info=>get_system_time( ).

    READ ENTITIES OF zr_rap_leavereq IN LOCAL MODE
      ENTITY LeaveRequest
      FIELDS ( Status )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_requests).

    LOOP AT lt_requests INTO DATA(ls_request).

      IF ls_request-Status <> 'SUBMITTED'.
        APPEND VALUE #( %tky = ls_request-%tky ) TO failed-LeaveRequest.
        APPEND VALUE #(
          %tky = ls_request-%tky
          %msg = new_message_with_text(
                    severity = if_abap_behv_message=>severity-error
                    text     = 'Only submitted requests can be rejected' )
        ) TO reported-LeaveRequest.
        CONTINUE.
      ENDIF.

      MODIFY ENTITIES OF zr_rap_leavereq IN LOCAL MODE
        ENTITY LeaveRequest
        UPDATE FIELDS ( Status LastChangedBy LastChangedAt LocalLastChangedAt )
        WITH VALUE #(
          ( %tky = ls_request-%tky
            Status             = 'REJECTED'
            LastChangedBy      = lv_user )
         ""   LastChangedAt      = lv_now
         ""   LocalLastChangedAt = lv_now )
        ).

    ENDLOOP.

    READ ENTITIES OF zr_rap_leavereq IN LOCAL MODE
      ENTITY LeaveRequest
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).

    result = VALUE #( FOR ls_res IN lt_result
                      ( %tky = ls_res-%tky
                        %param = ls_res ) ).

  ENDMETHOD.

  METHOD SetInitialValues.

    READ ENTITIES OF zr_rap_leavereq IN LOCAL MODE
      ENTITY LeaveRequest
      FIELDS ( Status CreatedBy CreatedAt LastChangedBy LastChangedAt LocalLastChangedAt )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_requests).

    LOOP AT lt_requests INTO DATA(ls_request).

    data(lv_timestamp) = cl_abap_context_info=>get_system_time( ).

      MODIFY ENTITIES OF zr_rap_leavereq IN LOCAL MODE
        ENTITY LeaveRequest
        UPDATE FIELDS ( Status CreatedBy CreatedAt LastChangedBy LastChangedAt LocalLastChangedAt )
        WITH VALUE #(
          ( %tky = ls_request-%tky
            Status             = COND #( WHEN ls_request-Status IS INITIAL THEN 'DRAFT' ELSE ls_request-Status )
            CreatedBy          = sy-uname
            CreatedAt          = cl_abap_context_info=>get_system_date( )
            LastChangedBy      = sy-uname )
        "    LastChangedAt      = lv_timestamp
        "    LocalLastChangedAt = cl_abap_context_info=>get_system_date_time( ) )
        ).

    ENDLOOP.
  ENDMETHOD.

  METHOD CalculateTotalDays.

    READ ENTITIES OF zr_rap_leavereq IN LOCAL MODE
      ENTITY LeaveRequest
      FIELDS ( StartDate EndDate )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_requests).

    LOOP AT lt_requests INTO DATA(ls_request).

      DATA(lv_days) = 0.

      IF ls_request-StartDate IS NOT INITIAL
         AND ls_request-EndDate IS NOT INITIAL
         AND ls_request-EndDate >= ls_request-StartDate.

        lv_days = ls_request-EndDate - ls_request-StartDate + 1.
      ENDIF.

      MODIFY ENTITIES OF zr_rap_leavereq IN LOCAL MODE
        ENTITY LeaveRequest
        UPDATE FIELDS ( TotalDays )
        WITH VALUE #(
          ( %tky = ls_request-%tky
            TotalDays = lv_days )
        ).

    ENDLOOP.

  ENDMETHOD.

  METHOD ValidateMandatoryFields.

    READ ENTITIES OF zr_rap_leavereq IN LOCAL MODE
      ENTITY LeaveRequest
      FIELDS ( EmployeeID EmployeeName LeaveType StartDate EndDate )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_requests).

    LOOP AT lt_requests INTO DATA(ls_request).

      IF ls_request-EmployeeID IS INITIAL.
        APPEND VALUE #( %tky = ls_request-%tky ) TO failed-LeaveRequest.
        APPEND VALUE #(
          %tky = ls_request-%tky
          %msg = new_message_with_text(
                    severity = if_abap_behv_message=>severity-error
                    text     = 'Employee ID is mandatory' )
          %element-EmployeeID = if_abap_behv=>mk-on
        ) TO reported-LeaveRequest.
      ENDIF.

      IF ls_request-EmployeeName IS INITIAL.
        APPEND VALUE #( %tky = ls_request-%tky ) TO failed-LeaveRequest.
        APPEND VALUE #(
          %tky = ls_request-%tky
          %msg = new_message_with_text(
                    severity = if_abap_behv_message=>severity-error
                    text     = 'Employee Name is mandatory' )
          %element-EmployeeName = if_abap_behv=>mk-on
        ) TO reported-LeaveRequest.
      ENDIF.

      IF ls_request-LeaveType IS INITIAL.
        APPEND VALUE #( %tky = ls_request-%tky ) TO failed-LeaveRequest.
        APPEND VALUE #(
          %tky = ls_request-%tky
          %msg = new_message_with_text(
                    severity = if_abap_behv_message=>severity-error
                    text     = 'Leave Type is mandatory' )
          %element-LeaveType = if_abap_behv=>mk-on
        ) TO reported-LeaveRequest.
      ENDIF.

      IF ls_request-StartDate IS INITIAL.
        APPEND VALUE #( %tky = ls_request-%tky ) TO failed-LeaveRequest.
        APPEND VALUE #(
          %tky = ls_request-%tky
          %msg = new_message_with_text(
                    severity = if_abap_behv_message=>severity-error
                    text     = 'Start Date is mandatory' )
          %element-StartDate = if_abap_behv=>mk-on
        ) TO reported-LeaveRequest.
      ENDIF.

      IF ls_request-EndDate IS INITIAL.
        APPEND VALUE #( %tky = ls_request-%tky ) TO failed-LeaveRequest.
        APPEND VALUE #(
          %tky = ls_request-%tky
          %msg = new_message_with_text(
                    severity = if_abap_behv_message=>severity-error
                    text     = 'End Date is mandatory' )
          %element-EndDate = if_abap_behv=>mk-on
        ) TO reported-LeaveRequest.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD ValidateDates.

     READ ENTITIES OF zr_rap_leavereq IN LOCAL MODE
      ENTITY LeaveRequest
      FIELDS ( StartDate EndDate )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_requests).

    LOOP AT lt_requests INTO DATA(ls_request).

      IF ls_request-StartDate IS NOT INITIAL
         AND ls_request-EndDate IS NOT INITIAL
         AND ls_request-EndDate < ls_request-StartDate.

        APPEND VALUE #( %tky = ls_request-%tky ) TO failed-LeaveRequest.

        APPEND VALUE #(
          %tky = ls_request-%tky
          %msg = new_message_with_text(
                    severity = if_abap_behv_message=>severity-error
                    text     = 'End Date cannot be before Start Date' )
          %element-EndDate = if_abap_behv=>mk-on
        ) TO reported-LeaveRequest.

      ENDIF.

    ENDLOOP.

   ENDMETHOD.

ENDCLASS.
