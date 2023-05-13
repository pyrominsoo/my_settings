= INCLUDES =
#include <tlm_utils/simple_target_socket.h>
#include <tlm_utils/peq_with_cb_and_phase.h>

= DEFINES =
tlm_utils::simple_target_socket<ClassName> TSOCKET;
tlm_utils::peq_with_cb_and_phase<ClassName> TARG_PEQ_NAME;

= INITLIST =
TSOCKET("TSOCKET"),
TARG_PEQ_NAME(this, &ClassName::TARG_PEQ_CALLBACK);

= CONSTRUCTOR =
TSOCKET.register_nb_transport_fw(this, &ClassName::nb_transport_fw);
TSOCKET.register_b_transport(this, &ClassName::b_transport);

= FUNCTIONS =
void b_transport(tlm::tlm_generic_payload &trans, sc_time &delay) {
    if (trans.get_command() == tlm::TLM_READ_COMMAND) {
        // Do something
    } else if (trans.get_command() == tlm::TLM_WRITE_COMMAND) {
        // Do something
    } else {
        // Do something
    }
    trans.set_response_status(tlm::TLM_OK_RESPONSE);
}

tlm::tlm_sync_enum nb_transport_fw(tlm::tlm_generic_payload &payload,
                                         tlm::tlm_phase &phase,
                                         sc_time &bwDelay) {
    payload.acquire();
    TARG_PEQ_NAME.notify(payload, phase, bwDelay);
    return tlm::TLM_ACCEPTED;
}

void TARG_PEQ_CALLBACK(tlm::tlm_generic_payload &payload,
                                  const tlm::tlm_phase &phase) {
    if (phase == tlm::BEGIN_REQ) {
        // do something
        sc_time fw_delay = sc_time(SC_ZERO_TIME);
        tlm::tlm_phase fw_phase = tlm::END_REQ;
        tlm::tlm_sync_enum status;
        status = TSOCKET->nb_transport_bw(payload, fw_phase, fw_delay);
    } else if (phase == tlm::END_RESP) {
        // Do something
        payload.release();
    } else {
        SC_REPORT_FATAL("ClassName", "MSG");
    }
}



