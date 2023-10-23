tlm::tlm_phase phase = tlm::BEGIN_REQ;
sc_time fw_delay = DELAY;
tlm::tlm_sync_enum status =
    master->nb_transport_fw(*trans, phase, fw_delay);
if (trans->get_response_status() != tlm::TLM_OK_RESPONSE) {
    SC_REPORT_FATAL(name(), "Did not receive TLM_OK_RESPONSE");
}
