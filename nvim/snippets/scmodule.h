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

class MODULENAME : public sc_module {
   public:
    /* SC_CTOR(MODULENAME) {} */
    SC_HAS_PROCESS(MODULENAME);

    tlm_utils::simple_initiator_socket<ClassName> ISOCKET;
    tlm_utils::peq_with_cb_and_phase<ClassName> INIT_PEQ_NAME;

    tlm_utils::simple_target_socket<ClassName> TSOCKET;
    tlm_utils::peq_with_cb_and_phase<ClassName> TARG_PEQ_NAME;

    MODULENAME(sc_module_name name)
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

    void sendFunc() {
        tlm::tlm_generic_payload *trans = GET_GLOBAL_TRANSACTION();
        trans->acquire();
        trans->set_command(TLM_WRITE_COMMAND);
        trans->set_address(TRANSADDR);
        trans->set_data_ptr(reinterpret_cast<unsigned char *>(DATAPTR));
        trans->set_data_length(DATALEN);
        trans->set_streaming_width(STREAMWIDTH);
        trans->set_byte_enable_ptr(0);
        trans->set_dmi_allowed(false);
        trans->set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
        sc_time fw_delay = sc_time(SC_ZERO_TIME);
        tlm_phase phase = BEGIN_REQ;
        tlm::tlm_sync_enum status;
        status = ISOCKET->nb_transport_fw(*trans, phase, fw_delay);
        if (status == TLM_ACCEPTED) {
            in_req = true;
        } else {  // TLM_UPDATED, TLM_COMPLETE
            SC_REPORT_ERROR("ClassName", "MSG");
        }
    }
    tlm_sync_enum ClassName::nb_transport_bw(tlm_generic_payload &payload,
                                             tlm_phase &phase,
                                             sc_time &bwDelay) {
        INIT_PEQ_NAME.notify(payload, phase, bwDelay);
        return TLM_ACCEPTED;
    }
    void ClassName::INIT_PEQ_CALLBACK(tlm_generic_payload &payload,
                                      const tlm_phase &phase) {
        if (phase == END_REQ) {
            // do something
        } else if (phase == BEGIN_RESP) {
            // Do something

            sc_time fw_delay = sc_time(SC_ZERO_TIME);
            tlm_phase fw_phase = END_RESP;
            tlm::tlm_sync_enum status;
            status = ISOCKET->nb_transport_fw(payload, fw_phase, fw_delay);
            payload.release();
        } else {
            SC_REPORT_FATAL("ClassName", "MSG");
        }
    }

    void nand_b_transport(tlm::tlm_generic_payload &trans, sc_time &delay) {
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
                                             tlm_phase &phase,
                                             sc_time &bwDelay) {
        payload.acquire();
        TARG_PEQ_NAME.notify(payload, phase, bwDelay);
        return TLM_ACCEPTED;
    }

    void ClassName::TARG_PEQ_CALLBACK(tlm_generic_payload &payload,
                                      const tlm_phase &phase) {
        if (phase == BEGIN_REQ) {
            // do something
            sc_time fw_delay = sc_time(SC_ZERO_TIME);
            tlm_phase fw_phase = END_REQ;
            tlm::tlm_sync_enum status;
            status = TSOCKET->nb_transport_bw(payload, fw_phase, fw_delay);
        } else if (phase == END_RESP) {
            // Do something
            payload.release();
        } else {
            SC_REPORT_FATAL("ClassName", "MSG");
        }
    }

   private:
};

#endif  // SYSTEMC_MODULE_SNIPPET_H
