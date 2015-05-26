/*
 * Copyright 2014-2015 CyberVision, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <stdio.h>
#include <time.h>

#include "kaa/kaa_error.h"
#include "kaa/platform/kaa_client.h"
#include "kaa/kaa_notification_manager.h"


void on_notification(void *context, uint64_t *topic_id, kaa_notification_t *notification)
{
    const int BUF_SIZE = 255;
    char buffer[BUF_SIZE];
    snprintf(buffer, BUF_SIZE, "echo \"%s\" | ./dcled", notification->message->data);
    for (int32_t i = 0; i < notification->repeat; ++i) {
#if 1
        system(buffer);
#else
        printf("Executing: %s\n", buffer);
#endif
    }
}


int main()
{
    kaa_client_t *kaa_client = NULL;
    kaa_error_t error_code = kaa_client_create(&kaa_client, NULL);
    if (error_code)
        return error_code;

    kaa_notification_listener_t notification_listener = { &on_notification, kaa_client };
    error_code = kaa_add_notification_listener(
            kaa_client_get_context(kaa_client)->notification_manager, &notification_listener, NULL);
    if (error_code)
        return error_code;

    // Start main loop
    error_code = kaa_client_start(kaa_client, NULL, NULL, 0);
    if (error_code)
        return error_code;

    kaa_client_destroy(kaa_client);
    return error_code;
}
