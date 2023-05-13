/*
 * ----------------------------------------------------------------------
 *        (c) copyright 2023. All rights reserved. Western Digital
 *         Company confidential and proprietary information.
 *  This information may not be disclosed to unauthorized individual.
 * ----------------------------------------------------------------------
 * @author: Min Soo Kim     min.soo.kim@wdc.com
 * @date:   05/12/2023
 */
#ifndef SYSTEMC_MODULE_SNIPPET_H
#define SYSTEMC_MODULE_SNIPPET_H

#include <tlm_utils/peq_with_cb_and_phase.h>
#include <tlm_utils/simple_initiator_socket.h>
#include <tlm_utils/simple_target_socket.h>

#include <systemc>
#include "sysc/kernel/sc_event.h"

using namespace sc_core;

class ClassName : public sc_module {
   public:
    /* SC_CTOR(ClassName) {} */
    SC_HAS_PROCESS(ClassName);

    tlm_utils::simple_initiator_socket<ClassName> ISOCKET;
    tlm_utils::peq_with_cb_and_phase<ClassName> INIT_PEQ_NAME;

    tlm_utils::simple_target_socket<ClassName> TSOCKET;
    tlm_utils::peq_with_cb_and_phase<ClassName> TARG_PEQ_NAME;

    sc_event SENDFUNC_EVENT;

    ClassName(sc_module_name name)
        : sc_module(name),
          ISOCKET("ISOCKET"),
          INIT_PEQ_NAME(this, &ClassName::INIT_PEQ_CALLBACK),
          TSOCKET("TSOCKET"),
          TARG_PEQ_NAME(this, &ClassName::TARG_PEQ_CALLBACK) {
        ISOCKET.register_nb_transport_bw(this, &ClassName::nb_transport_bw);
        TSOCKET.register_nb_transport_fw(this, &ClassName::nb_transport_fw);
        TSOCKET.register_b_transport(this, &ClassName::b_transport);

        SC_METHOD(SENDFUNC);
        sensitive << SENDFUNC_EVENT;
    }

    void SENDFUNC() {
        tlm::tlm_generic_payload *trans = GET_GLOBAL_TRANSACTION();
        trans->acquire();
        trans->set_command(tlm::TLM_WRITE_COMMAND);
        trans->set_address(TRANSADDR);
        trans->set_data_ptr(reinterpret_cast<unsigned char *>(DATAPTR));
        trans->set_data_length(DATALEN);
        trans->set_streaming_width(STREAMWIDTH);
        trans->set_byte_enable_ptr(0);
        trans->set_dmi_allowed(false);
        trans->set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
        sc_time fw_delay = sc_time(SC_ZERO_TIME);
        tlm::tlm_phase phase = tlm::BEGIN_REQ;
        tlm::tlm_sync_enum status;
        status = ISOCKET->nb_transport_fw(*trans, phase, fw_delay);
        if (status == tlm::TLM_ACCEPTED) {
            // Do something
        } else {  // TLM_UPDATED, TLM_COMPLETE
            SC_REPORT_ERROR("ClassName", "MSG");
        }
    }
    tlm::tlm_sync_enum nb_transport_bw(tlm::tlm_generic_payload &payload,
                                             tlm::tlm_phase &phase,
                                             sc_time &bwDelay) {
        INIT_PEQ_NAME.notify(payload, phase, bwDelay);
        return tlm::TLM_ACCEPTED;
    }
    void INIT_PEQ_CALLBACK(tlm::tlm_generic_payload &payload,
                                      const tlm::tlm_phase &phase) {
        if (phase == tlm::END_REQ) {
            // do something
        } else if (phase == tlm::BEGIN_RESP) {
            // Do something

            sc_time fw_delay = sc_time(SC_ZERO_TIME);
            tlm::tlm_phase fw_phase = tlm::END_RESP;
            tlm::tlm_sync_enum status;
            status = ISOCKET->nb_transport_fw(payload, fw_phase, fw_delay);
            payload.release();
        } else {
            SC_REPORT_FATAL("ClassName", "MSG");
        }
    }

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

   private:
};

#endif  // SYSTEMC_MODULE_SNIPPET_H
