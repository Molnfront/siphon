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

#ifndef __SIPHON_CALL_H__
#define __SIPHON_CALL_H__

#include <pjsua-lib/pjsua.h>

PJ_BEGIN_DECL

pj_status_t sip_startup    ();
pj_status_t sip_cleanup    ();

pj_status_t sip_connect    (pjsua_acc_id *acc_id);
pj_status_t sip_disconnect (pjsua_acc_id *acc_id);

pj_status_t sip_dial       (pjsua_acc_id acc_id, const char *number, 
                            pjsua_call_id *call_id);
pj_status_t sip_answer     ();
pj_status_t sip_hangup     (pjsua_call_id *call_id);

PJ_END_DECL

#endif /* __SIPHON_CALL_H__ */
