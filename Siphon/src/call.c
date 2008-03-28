/**
 *  Siphon SIP-VoIP for iPhone and iPod Touch
 *  Copyright (C) 2008 Samuel <samuelv@users.sourceforge.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along
 *  with this program; if not, write to the Free Software Foundation, Inc.,
 *  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#include <pjsua-lib/pjsua.h>

#include "call.h"
#include "ring.h"
#include "dtmf.h"

#define THIS_FILE "call.c"

static pjsua_call_id   current_call = PJSUA_INVALID_ID;

/* Pjsua application data */
static struct app_config
{
  pj_pool_t             *pool;

  pjsua_config           cfg;
  pjsua_logging_config   log_cfg;
  pjsua_media_config     media_cfg;
  
  pjsua_transport_config udp_cfg;
  pjsua_transport_config rtp_cfg;
  
//  pjsua_acc_config       acc_cfg;
  
//  float mic_level;
//  float speaker_level;
} app_config;

/* Callback called by the library when call's state has changed */
static void on_call_state(pjsua_call_id call_id, pjsip_event *e)
{
  pjsua_call_info ci;
  
  PJ_UNUSED_ARG(e);
  
  pjsua_call_get_info(call_id, &ci);
  
  PJ_LOG(1,(THIS_FILE, "Call %d state=%.*s", call_id,
    (int)ci.state_text.slen, ci.state_text.ptr));
  
  /* Déconnexion */
  if (ci.state == PJSIP_INV_STATE_DISCONNECTED) 
  {
    // FIXME: mettre fin à la sonnerie si la personne a racrochée avant le
    // décrochage

    sip_call_deinit_tonegen(call_id);
    current_call = PJSUA_INVALID_ID;
  }
  else 
  {
    if (current_call == PJSUA_INVALID_ID)
      current_call = call_id;
  }
}

/* Callback called by the library upon receiving incoming call */
static void on_incoming_call(pjsua_acc_id acc_id, pjsua_call_id call_id,
           pjsip_rx_data *rdata)
{
  pjsua_call_info ci;

  PJ_UNUSED_ARG(acc_id);
  PJ_UNUSED_ARG(rdata);

  pjsua_call_get_info(call_id, &ci);

  PJ_LOG(1,(THIS_FILE, "Incoming call from %.*s!!",
     (int)ci.remote_info.slen,
     ci.remote_info.ptr));
  
  /* Automatically answer incoming calls with 200/OK */
  //pjsua_call_answer(call_id, 200, NULL, NULL);
  pjsua_call_answer(call_id, 180, NULL, NULL);

  sip_ring_startup(call_id);
  /*PJ_LOG(3,(THIS_FILE,
      "Incoming call for account %d!\n"
      "From: %s\n"
      "To: %s\n"
      "Press a to answer or h to reject call",
      acc_id,
      ci.remote_info.ptr,
      ci.local_info.ptr));*/
}

/* Callback called by the library when call's media state has changed */
static void on_call_media_state(pjsua_call_id call_id)
{
    pjsua_call_info ci;

    pjsua_call_get_info(call_id, &ci);
//    PJ_LOG(3,(THIS_FILE,"on_call_media_state status %d count %d",
//      ci.media_status
//      pjmedia_conf_get_connect_count()));

    if (ci.media_status == PJSUA_CALL_MEDIA_ACTIVE) 
    {
      // When media is active, connect call to sound device.
      pjsua_conf_connect(ci.conf_slot, 0);
      pjsua_conf_connect(0, ci.conf_slot);
      pjsua_conf_adjust_tx_level(0, 4.0);
      pjsua_conf_adjust_rx_level(0, 3.0);
    }
}

/* */
pj_status_t sip_startup()
{
  pj_status_t status;
  char tmp[80];

  /* Create pjsua first! */
  status = pjsua_create();
  if (status != PJ_SUCCESS)
    return status;

  /* Create pool for application */
  app_config.pool = pjsua_pool_create("pjsua", 1000, 1000);
  
  /* Initialize default config */
  pjsua_config_default(&(app_config.cfg));
  pj_ansi_snprintf(tmp, 80, "Siphon PjSip v%s/%s", pj_get_version(), PJ_OS_NAME);
  pj_strdup2_with_null(app_config.pool, &(app_config.cfg.user_agent), tmp);
  
  pjsua_logging_config_default(&(app_config.log_cfg));
  app_config.log_cfg.msg_logging = PJ_FALSE;
  app_config.log_cfg.console_level = 0;
  app_config.log_cfg.level = 0;
  
  pjsua_media_config_default(&(app_config.media_cfg));
  app_config.media_cfg.clock_rate = 8000;
  app_config.media_cfg.ec_tail_len = 0;
//  app_config.media_cfg.quality = 2;
  
  pjsua_transport_config_default(&(app_config.udp_cfg));
  app_config.udp_cfg.port = 5060;
  
  pjsua_transport_config_default(&(app_config.rtp_cfg));
  app_config.rtp_cfg.port = 4000;
  
  /* Initialize application callbacks */
  app_config.cfg.cb.on_incoming_call = &on_incoming_call;
  app_config.cfg.cb.on_call_media_state = &on_call_media_state;
  app_config.cfg.cb.on_call_state = &on_call_state;
  
  /* Initialize pjsua */
  status = pjsua_init(&app_config.cfg, &app_config.log_cfg, 
    &app_config.media_cfg);
  if (status != PJ_SUCCESS)
    goto error;

  /* Add UDP transport. */
  status = pjsua_transport_create(PJSIP_TRANSPORT_UDP,
          &app_config.udp_cfg, NULL/*&transport_id*/);
  if (status != PJ_SUCCESS)
    goto error;
      
  /* Add RTP transports */
  status = pjsua_media_transports_create(&app_config.rtp_cfg);
  if (status != PJ_SUCCESS)
    goto error;
 
  /* Initialization is done, now start pjsua */
  status = pjsua_start();

  return status;

error:
  pj_pool_release(app_config.pool);
  app_config.pool = NULL;
  return status;
}

/* */
pj_status_t sip_cleanup()
{
  pj_status_t status;

  if (app_config.pool) 
  {
    pj_pool_release(app_config.pool);
    app_config.pool = NULL;
  }

  /* Destroy pjsua */
  status = pjsua_destroy();
  
  pj_bzero(&app_config, sizeof(app_config));
  
  return status;
  
}

/* */
pj_status_t sip_connect(const char *server, 
  const char *uname, const char *passwd, pjsua_acc_id *acc_id)
{
  pj_status_t status;
  pjsua_acc_config acc_cfg;
  
  pjsua_acc_config_default(&acc_cfg);

  // ID
  acc_cfg.id.ptr = (char*) pj_pool_alloc(app_config.pool, PJSIP_MAX_URL_SIZE);
  acc_cfg.id.slen = pj_ansi_snprintf(acc_cfg.id.ptr, PJSIP_MAX_URL_SIZE, 
    "sip:%s@%s", uname, server);
  if (pjsua_verify_sip_url(acc_cfg.id.ptr) != 0) 
  {
    PJ_LOG(1,(THIS_FILE, "Error: invalid SIP URL '%s' in local id argument", 
      acc_cfg.id));
    return PJ_EINVAL;
  }
  
  // Registar
  acc_cfg.reg_uri.ptr = (char*) pj_pool_alloc(app_config.pool, 
    PJSIP_MAX_URL_SIZE);
  acc_cfg.reg_uri.slen = pj_ansi_snprintf(acc_cfg.reg_uri.ptr, 
    PJSIP_MAX_URL_SIZE, "sip:%s", server);
  if (pjsua_verify_sip_url(acc_cfg.reg_uri.ptr) != 0) 
  {
    PJ_LOG(1,(THIS_FILE,  "Error: invalid SIP URL '%s' in registrar argument", acc_cfg.reg_uri));
    return PJ_EINVAL;
  }

  //acc_cfg.id = pj_str(id);
  //acc_cfg.reg_uri = pj_str(registrar);
  acc_cfg.cred_count = 1;
  acc_cfg.cred_info[0].scheme = pj_str("Digest");
  acc_cfg.cred_info[0].realm = pj_str("*");//pj_str(realm);
  acc_cfg.cred_info[0].username = pj_str(uname);
  acc_cfg.cred_info[0].data_type = PJSIP_CRED_DATA_PLAIN_PASSWD;
  acc_cfg.cred_info[0].data = pj_str(passwd);
  acc_cfg.publish_enabled = PJ_TRUE;
  acc_cfg.reg_timeout = 1800; // FIXME: gestion du message 423 dans pjsip

//{
//  pjmedia_port *media_port = pjsua_set_no_snd_dev();
//}

  status = pjsua_acc_add(&acc_cfg, PJ_TRUE, acc_id);
  if (status != PJ_SUCCESS) 
  {
      pjsua_perror(THIS_FILE, "Error adding new account", status);
  }
  
  return status;
}

/* */
pj_status_t sip_disconnect(pjsua_acc_id *acc_id)
{
  pj_status_t status = PJ_SUCCESS;
  
  if (pjsua_acc_is_valid(*acc_id))
  {
    status = pjsua_acc_del(*acc_id);
    if (status == PJ_SUCCESS)
      *acc_id = PJSUA_INVALID_ID;
  }
  
  return status;
}

/* */
pj_status_t sip_dial(pjsua_acc_id acc_id, const char *number, 
  const char *sip_domain, pjsua_call_id *call_id)
{
  // FIXME: récupérer le domain à partir du compte (acc_id);
  
  pj_status_t status = PJ_SUCCESS;
  char uri[256];
  pj_str_t pj_uri;

  pj_ansi_snprintf(uri, 256, "sip:%s@%s", number, sip_domain);
  PJ_LOG(5,(THIS_FILE,  "Calling URI \"%s\".", uri));

  status = pjsua_verify_sip_url(uri);
  if (status != PJ_SUCCESS) 
  {
    PJ_LOG(1,(THIS_FILE,  "Invalid URL \"%s\".", uri));
    pjsua_perror(THIS_FILE, "Invalid URL", status);
    return status;
  }
  
  pj_uri = pj_str(uri);
  
  status = pjsua_call_make_call(acc_id, &pj_uri, 0, NULL, NULL, call_id);
  if (status != PJ_SUCCESS)
  {
    pjsua_perror(THIS_FILE, "Error making call", status);
  }
  
  return status;
  
}

/* */
pj_status_t sip_answer(pjsua_call_id *call_id)
{
  pj_status_t status;
  
  sip_ring_cleanup(current_call);

  status = pjsua_call_answer(current_call, 200, NULL, NULL);
  *call_id = (status == PJ_SUCCESS ? current_call : PJSUA_INVALID_ID);
  
  return status;
}

/* */
pj_status_t sip_hangup(pjsua_call_id *call_id)
{
  pj_status_t status = PJ_SUCCESS;
  
  pjsua_call_hangup_all();
  /* Hangup current calls */
  //status = pjsua_call_hangup(*call_id, 0, NULL, NULL);
  *call_id = PJSUA_INVALID_ID;
  
  return status;
}

