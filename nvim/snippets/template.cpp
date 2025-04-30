#ifndef TEMPLATE_H
#define TEMPLATE_H

#include <tlm_utils/peq_with_cb_and_phase.h>
#include <tlm_utils/simple_initiator_socket.h>
#include <tlm_utils/simple_target_socket.h>

#include <systemc>

#include "base/statistics.hh"
#include "base/stats/group.hh"
#include "common/trans_pool.h"
#include "sim/stats_root.hh"

using namespace sc_core;

class MODULE : public sc_module {
   public:
    tlm_utils::simple_target_socket<MODULE> TSCKT;
    tlm_utils::peq_with_cb_and_phase<MODULE> TSCKT_PEQ;
    tlm_utils::simple_initiator_socket<MODULE> ISCKT;
    tlm_utils::peq_with_cb_and_phase<MODULE> ISCKT_PEQ;

    sc_event send_e;

    SC_HAS_PROCESS(MODULE);
    MODULE(sc_module_name name)
        : TSCKT("TSCKT"),
          TSCKT_PEQ(this, &MODULE::TSCKT_PEQ_CB),
          ISCKT("ISCKT"),
          ISCKT_PEQ(this, &MODULE::ISCKT_PEQ_CB),
          trans_pool_(),
          stats_(&stats::statsRoot, this->name(), this) {
        TSCKT.register_nb_transport_fw(this, &MODULE::nb_transport_fw);
        ISCKT.register_nb_transport_bw(this, &MODULE::nb_transport_bw);

        SC_METHOD(Send);
        sensitive << send_e;
        dont_initialize();
    }

    ~MODULE() {}

    void Send() {
        // Condition check
        // Prep

        tlm::tlm_generic_payload* trans = trans_pool_.GetTrans();
        trans->acquire();

        trans->set_command(tlm::TLM_WRITE_COMMAND);
        trans->set_address(0);
        trans->set_data_length(0);
        trans->set_data_ptr(reinterpret_cast<unsigned char*>(0));
        sc_time fw_delay = sc_time(SC_ZERO_TIME);
        tlm::tlm_phase phase = tlm::BEGIN_REQ;
        trans->set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
        tlm::tlm_sync_enum status =
            ISCKT->nb_transport_fw(*trans, phase, fw_delay);
        if (trans->get_response_status() != tlm::TLM_OK_RESPONSE) {
            SC_REPORT_FATAL(name(), "No TLM_OK_RESPONSE");
        }
    }

    tlm::tlm_sync_enum nb_transport_fw(tlm::tlm_generic_payload& trans,
                                       tlm::tlm_phase& phase, sc_time& delay) {
        TSCKT_PEQ.notify(trans, phase, delay);
        trans.set_response_status(tlm::TLM_OK_RESPONSE);
        return tlm::TLM_ACCEPTED;
    }

    tlm::tlm_sync_enum nb_transport_bw(tlm::tlm_generic_payload& trans,
                                       tlm::tlm_phase& phase, sc_time& delay) {
        ISCKT_PEQ.notify(trans, phase, delay);
        trans.set_response_status(tlm::TLM_OK_RESPONSE);
        return tlm::TLM_ACCEPTED;
    }

    void TSCKT_PEQ_CB(tlm::tlm_generic_payload& trans,
                      const tlm::tlm_phase& phase) {
        if (phase == tlm::BEGIN_REQ) {
            trans.acquire();

            sc_time bw_delay = sc_time(SC_ZERO_TIME);
            tlm::tlm_phase phase = tlm::END_REQ;
            trans.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
            tlm::tlm_sync_enum status =
                TSCKT->nb_transport_bw(trans, phase, bw_delay);
            if (trans.get_response_status() != tlm::TLM_OK_RESPONSE) {
                SC_REPORT_FATAL(name(), "No TLM_OK_RESPONSE");
            }

        } else if (phase == tlm::END_RESP) {
            trans.release();
        } else {
            SC_REPORT_FATAL(name(), "Unexpected phase");
        }
    }

    void ISCKT_PEQ_CB(tlm::tlm_generic_payload& trans,
                      const tlm::tlm_phase& phase) {
        if (phase == tlm::END_REQ) {
            send_e.notify();
        } else if (phase == tlm::BEGIN_RESP) {
            sc_time fw_delay = sc_time(SC_ZERO_TIME);
            tlm::tlm_phase phase = tlm::END_RESP;
            trans.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
            tlm::tlm_sync_enum status =
                ISCKT->nb_transport_fw(trans, phase, fw_delay);
            if (trans.get_response_status() != tlm::TLM_OK_RESPONSE) {
                SC_REPORT_FATAL(name(), "No TLM_OK_RESPONSE");
            }

            trans.release();
        } else {
            SC_REPORT_FATAL(name(), "Unexpected phase");
        }
    }

   private:
    TransPool trans_pool_;

    struct MxuCtrlStats : public gem5::statistics::Group {
        MxuCtrlStats(gem5::statistics::Group* parent, const char* name,
                     MODULE* owner)
            : gem5::statistics::Group(parent, name),
              ADD_STAT(num_mxujob, gem5::statistics::units::Count::get(),
                       "Number of MxuJob completed"),
              ADD_STAT(mxujob_rate, gem5::statistics::units::Ratio::get(),
                       "Rate of MxuJob completion (tile/sec)"),
              owner(owner) {}

        void regStats() {
            gem5::statistics::Group::regStats();

            mxujob_rate.prereq(num_mxujob)
                .method(this, &MxuCtrlStats::GetMxuJobRate);

            // assign.init(owner->GetNumMxu());
            // for (int i = 0; i < owner->num_mxu_; ++i) {
            //     assign.subname(i, "MXU" + std::to_string(i));
            // }
        }

        double GetMxuJobRate() const {
            double rate = num_mxujob.result() / sc_time_stamp().to_seconds();
            return rate;
        }

        gem5::statistics::Scalar num_mxujob;
        gem5::statistics::Value mxujob_rate;
        // gem5::statistics::Vector assign;

        MODULE* owner;
    } stats_;
};

#endif  // TEMPLATE_H

