
INCLUDES
#include <tlm_utils/simple_initiator_socket.h>
#include <tlm_utils/peq_with_cb_and_phase.h>

DEFINES
tlm_utils::simple_initiator_socket<ClassName> ISOCKET;
tlm_utils::peq_with_cb_and_phase<ClassName> PEQNAME;
tlm::tlm_generic_payload TRANS;

INITLIST
ISOCKET("ISOCKET"),
PEQNAME(this, &ClassName::peqCallback);

CONSTRUCTOR
ISOCKET.register_nb_transport_bw(this, &ClassName::nb_transport_bw);

SENDING
void sendFunc () {
    tlm::tlm_generic_payload * trans = GET_GLOBAL_TRANSACTION();
    trans->acquire();
    trans->set_command(TLM_WRITE_COMMAND);
    trans->set_address( TRANSADDR );
    trans->set_data_ptr( reinterpret_cast<unsigned char*>(DATAPTR) );
    trans->set_data_length( DATALEN );
    trans->set_streaming_width( STREAMWIDTH );
    trans->set_byte_enable_ptr( 0 );
    trans->set_dmi_allowed( false );
    trans->set_response_status( tlm::TLM_INCOMPLETE_RESPONSE );
    sc_time fw_delay = sc_time(SC_ZERO_TIME);
    tlm_phase phase = BEGIN_REQ;
    tlm::tlm_sync_enum status;
    status = ISOCKET->nb_transport_fw( *trans, phase, fw_delay );
    ISOCKET->b_transport(TRANS, fw_delay);
    if (status == TLM_ACCEPTED) {
        in_req = true;
    }
    else { // TLM_UPDATED, TLM_COMPLETE
        SC_REPORT_ERROR("ClassName", "MSG");
    }
    AT(!TRANS.is_response_error(), "Response error from b_transport");
}
tlm_sync_enum ClassName::nb_transport_bw(tlm_generic_payload &payload,
                                           tlm_phase &phase, sc_time &bwDelay)
{
    PEQNAME.notify(payload, phase, bwDelay);
    return TLM_ACCEPTED;
}
void ClassName::peqCallback(tlm_generic_payload &payload, const tlm_phase &phase)
{
    if (phase == END_REQ) {
        // do something
    }
    else if (phase == BEGIN_RESP)
    {
        // Do something

        sc_time fw_delay = sc_time(SC_ZERO_TIME);
        tlm_phase fw_phase = END_RESP;
        tlm::tlm_sync_enum status;
        status = ISOCKET->nb_transport_fw(payload, fw_phase, fw_delay);
        payload.release();
    }
    else
    {
        SC_REPORT_FATAL("ClassName", "MSG");
    }
}
