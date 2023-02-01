INCLUDES
#include <tlm_utils/simple_target_socket.h>
#include <tlm_utils/peq_with_cb_and_phase.h>

DEFINES
tlm_utils::simple_target_socket<ClassName> TSOCKET;
tlm_utils::peq_with_cb_and_phase<ClassName> PEQNAME;
tlm::tlm_generic_payload TRANS;

INITLIST
TSOCKET("TSOCKET"),
PEQNAME(this, &ClassName::peqCallback);

CONSTRUCTOR
TSOCKET.register_nb_transport_fw(this, &ClassName::nb_transport_fw);
TSOCKET.register_b_transport(this, &ClassName::b_transport);

FUNCTIONS
void nand_b_transport(tlm::tlm_generic_payload& trans,
                              sc_time& delay) {
    if (trans.get_command() == TLM_READ_COMMAND) {
        LG5("NAND: that was READ");
    } else if (trans.get_command() == TLM_WRITE_COMMAND) {
        LG5("NAND: that was WRITE");
    } else {
        LG5("NAND: ERROR: UNEXPECTED opcode received");
    }
    trans.set_response_status(tlm::TLM_OK_RESPONSE);
}
tlm_sync_enum ClassName::nb_transport_fw(tlm_generic_payload &payload,
                                           tlm_phase &phase, sc_time &bwDelay)
{
    payload.acquire();
    PEQNAME.notify(payload, phase, bwDelay);
    return TLM_ACCEPTED;
}
void ClassName::peqCallback(tlm_generic_payload &payload, const tlm_phase &phase)
{
    if (phase == BEGIN_REQ) {
        // do something
        sc_time fw_delay = sc_time(SC_ZERO_TIME);
        tlm_phase fw_phase = END_REQ;
        tlm::tlm_sync_enum status;
        status = TSOCKET->nb_transport_bw(payload, fw_phase, fw_delay);
    }
    else if (phase == END_RESP)
    {
        // Do something
        payload.release();
    }
    else
    {
        SC_REPORT_FATAL("ClassName", "MSG");
    }
}
