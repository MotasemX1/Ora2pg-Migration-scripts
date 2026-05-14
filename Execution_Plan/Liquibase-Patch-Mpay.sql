INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('878-feat-add-posting-time-on-jv-ddl', 'SYSTEM', './scripts/core-jo/shared/51-878-feat-add-posting-time-on-jv.xml', '2023-01-31 15:51:27.327', 619, 'EXECUTED', '8:0d5ac93005bf601eadabf9b8f9427154', 'addColumn tableName=mpay_jvdetails', '', NULL, '3.8.2', NULL, NULL, '5173085879');
INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('878-feat-add-posting-time-on-jv', 'MAJED', './scripts/core-jo/shared/51-878-feat-add-posting-time-on-jv.xml', '2023-01-31 15:51:27.341', 620, 'EXECUTED', '8:2d0d7e236d71504638a46ce07f967371', 'sql', '', NULL, '3.8.2', NULL, NULL, '5173085879');
INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('drop-old-post_journal_voucher_function_and_create_new_one_postgressql-v2', 'MAJED', './scripts/core-jo/shared/51-878-feat-add-posting-time-on-jv.xml', '2023-01-31 15:51:27.360', 621, 'EXECUTED', '8:a27ae0f97e61855ed1f4383c1d1a6555', 'sqlFile', '', NULL, '3.8.2', NULL, NULL, '5173085879');
INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('posting-time-max-length', 'MAJED', './scripts/core-jo/shared/51-878-feat-add-posting-time-on-jv.xml', '2023-01-31 15:51:27.371', 622, 'EXECUTED', '8:76ae6495fdc58182c58795f869516e3c', 'sql', '', NULL, '3.8.2', NULL, NULL, '5173085879');
INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('add-posting-time-form-field-on-journal-voucher-view', 'SYSTEM', './scripts/core-jo/shared/51-878-feat-add-posting-time-on-jv.xml', '2023-01-31 15:51:27.382', 623, 'EXECUTED', '8:7fda1e35a7ccd82ec758d0881291b574', 'sql', '', NULL, '3.8.2', NULL, NULL, '5173085879');
INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('change-order-value-for-posting-time-property-in-jv-details', 'SYSTEM', './scripts/core-jo/shared/51-878-feat-add-posting-time-on-jv.xml', '2023-01-31 15:51:27.396', 624, 'EXECUTED', '8:4f3c47033711fc1d7d4e429991f852c8', 'sql', '', NULL, '3.8.2', NULL, NULL, '5173085879');
INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('fix-getBalByWalletType-stored-procedure-postgres', 'LOLAH', './scripts/core-jo/shared/55-874-fix-get-bal-by-wallet-type.xml', '2023-01-31 15:51:27.571', 631, 'EXECUTED', '8:b47edf25d645375e1f5320efe910dea5', 'createProcedure procedureName=getBalByWalletType', '', NULL, '3.8.2', NULL, NULL, '5173085879');
INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('fix-getBalByWalletType-stored-procedure-oracle', 'LOLAH', './scripts/core-jo/shared/55-874-fix-get-bal-by-wallet-type.xml', '2023-01-31 15:51:27.592', 632, 'EXECUTED', '8:34695a9d2801a6574829ffeb1d198b06', 'createProcedure procedureName=getBalByWalletType', '', NULL, '3.8.2', NULL, NULL, '5173085879');
INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('156-feat-enable-creditor-limit-get-account-limit-procedure', 'ANAS', './scripts/core-jo/shared/156-feat-enable-creditor-limit.xml', '2024-08-28 14:57:06.946', 961, 'EXECUTED', '8:b8765f46e5722985d343cdbb3b7aac81', 'sqlFile', '', NULL, '3.8.2', NULL, NULL, '4846224977');
INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('98-1052-add-switch-wallet-sysconfig', 'SYSTEM', './scripts/core-jo/shared/98-1052-add-switch-wallet-sysconfig.xml', '2023-07-03 22:35:53.707', 755, 'EXECUTED', '8:ccd7fa03f5caa5ea395d009f66c21df0', 'sql', '', NULL, '3.8.2', NULL, NULL, '8412953538');
INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('98-change-db-amount-type', 'LOLAH', './scripts/core-jo/shared/98-1052-add-switch-wallet-sysconfig.xml', '2023-07-03 22:35:53.785', 756, 'EXECUTED', '8:8dd5513f8f1cd0ef7f0d4b138e6ea808', 'sql', '', NULL, '3.8.2', NULL, NULL, '8412953538');
INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('remove-nullable-constraint-ps', 'LOLAH', './scripts/core-jo/shared/107-make-request-id-nulable.xml', '2023-07-29 23:15:03.419', 789, 'EXECUTED', '8:b2082964a10570ae8e2e54d059ece042', 'sql', '', NULL, '3.8.2', NULL, NULL, '0661703258');
INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('107-make-request-id-nulable', 'LOLAH', './scripts/core-jo/shared/107-make-request-id-nulable.xml', '2023-07-29 23:15:03.431', 790, 'EXECUTED', '8:6330b98472451318159ce4bf4c530d6c', 'sql', '', NULL, '3.8.2', NULL, NULL, '0661703258');
INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('create-trigger-postgresql', 'ahmad_lolah', './scripts/core-jo/shared/119-update-customer-prof-trigger.xml', '2023-10-25 10:10:18.113', 821, 'EXECUTED', '8:18d011d836dfce9a80678ecb4b0b18ac', 'createProcedure procedureName=TRG_CUSTOMERPROFILE', '', NULL, '3.8.2', NULL, NULL, '8217816974');
INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('Update-post_journal_voucher_function_and_create_new_one_postgressql-v2', 'ANAS', './scripts/core-jo/shared/130-resolve-deadlock-issue.xml', '2024-01-28 18:05:06.718', 864, 'EXECUTED', '8:f360157db1714d5dd22d9ea6e2345d20', 'sqlFile', '', NULL, '3.8.2', NULL, NULL, '6454306444');
INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('add-unique-constraints-on-mpclearcode-and-ismpcleardefault-postgres', 'MAJED', './scripts/core-jo/shared/137-add-unique-constraints-on-mpclearcode-and-ismpcleardefault.xml', '2024-04-02 12:39:29.026', 882, 'EXECUTED', '8:d7f2e231b6c3c16d37b8ecb0277d5870', 'sql', '', NULL, '3.8.2', NULL, NULL, '2050768678');
INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('add-unique-constraints-on-mpclearcode-and-ismpcleardefault-shared', 'MAJED', './scripts/core-jo/shared/137-add-unique-constraints-on-mpclearcode-and-ismpcleardefault.xml', '2024-04-02 12:39:29.055', 883, 'EXECUTED', '8:c4de5ca6a25da8cfbde4c6bca87d8c82', 'sql', '', NULL, '3.8.2', NULL, NULL, '2050768678');
INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('add-unique-constraints-on-mpclearcode-and-ismpcleardefault-postgres-v2', 'MAJED', './scripts/core-jo/shared/137-add-unique-constraints-on-mpclearcode-and-ismpcleardefault.xml', '2024-04-02 12:39:29.076', 884, 'EXECUTED', '8:a87ef45ee64723a42e6679658900655f', 'sql', '', NULL, '3.8.2', NULL, NULL, '2050768678');
INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('20240307-add-system-configurations', 'MPAY', './scripts/core-jo/shared/mportal/application-data.xml', '2024-08-12 18:04:42.874', 930, 'EXECUTED', '8:b80472d9d2f49805ff1cff426d4a1129', 'sql; insert tableName=mpay_sysconfigs; sql', '', NULL, '3.8.2', NULL, NULL, '3475081559');
INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('20240703-001-update-reject-flag-user', 'MPAY', './scripts/core-jo/shared/mportal/application-data.xml', '2024-08-12 18:04:42.881', 931, 'EXECUTED', '8:418641be8d56470cd305bbc9f423991b', 'update tableName=MPAY_MPORTALUSERS', '', NULL, '3.8.2', NULL, NULL, '3475081559');
INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('2024071401-add-system-configurations', 'MPAY', './scripts/core-jo/shared/mportal/application-data.xml', '2024-08-12 18:04:42.892', 932, 'EXECUTED', '8:c540246454822acaec6dcd450645f604', 'sql; insert tableName=mpay_sysconfigs; sql', '', NULL, '3.8.2', NULL, NULL, '3475081559');
INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('2024071401-addSysConfigs-for-left-logo-image', 'MPAY', './scripts/core-jo/shared/mportal/application-data.xml', '2024-08-12 18:04:42.899', 933, 'EXECUTED', '8:437360cfcedb97cf76b3b7b2f7e2409f', 'sql; insert tableName=mpay_sysconfigs; sql', '', NULL, '3.8.2', NULL, NULL, '3475081559');
INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('2024071402-addSysConfigs-for-logo-image', 'MPAY', './scripts/core-jo/shared/mportal/application-data.xml', '2024-08-12 18:04:42.906', 934, 'EXECUTED', '8:1174e38ced09efde9b885093899dfdc6', 'sql; insert tableName=mpay_sysconfigs; sql', '', NULL, '3.8.2', NULL, NULL, '3475081559');
INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('2024071403-addSysConfigs-for-Sending PSP BIC Code', 'MPAY', './scripts/core-jo/shared/mportal/application-data.xml', '2024-08-12 18:04:42.912', 935, 'EXECUTED', '8:e23dfca904fd9c65c717e3292d941cd2', 'sql; insert tableName=mpay_sysconfigs; sql', '', NULL, '3.8.2', NULL, NULL, '3475081559');
INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('2024072301-addSysConfigs-for-dashboard-mportal', 'MPAY', './scripts/core-jo/shared/mportal/application-data.xml', '2024-08-12 18:04:42.922', 936, 'EXECUTED', '8:45d97dd8ad7646a01b3442e5053ca939', 'sql; insert tableName=mpay_sysconfigs; insert tableName=mpay_sysconfigs; insert tableName=mpay_sysconfigs; insert tableName=mpay_sysconfigs; sql', '', NULL, '3.8.2', NULL, NULL, '3475081559');
INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('2024072302-addSysConfigs-for-endpoints-mportal', 'MPAY', './scripts/core-jo/shared/mportal/application-data.xml', '2024-08-12 18:04:42.939', 937, 'EXECUTED', '8:d5eb0826a89b300fa24701d2b7698e40', 'sql; insert tableName=mpay_sysconfigs; insert tableName=mpay_sysconfigs; insert tableName=mpay_sysconfigs; insert tableName=mpay_sysconfigs; insert tableName=mpay_sysconfigs; sql', '', NULL, '3.8.2', NULL, NULL, '3475081559');
INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('2024072303-addSysConfigs-for-endpoints-mportal-service-registration', 'MPAY', './scripts/core-jo/shared/mportal/application-data.xml', '2024-08-12 18:04:42.945', 938, 'EXECUTED', '8:e5b4b59c2384aa0b3e155a768c4dca8e', 'sql; insert tableName=mpay_sysconfigs; sql', '', NULL, '3.8.2', NULL, NULL, '3475081559');
INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('2024072801-addSysConfigs-for-endpoint-mportal-qr-generation-endpoint', 'MPAY', './scripts/core-jo/shared/mportal/application-data.xml', '2024-08-12 18:04:42.952', 939, 'EXECUTED', '8:4157a21c802fe22502373a052753c153', 'sql; insert tableName=mpay_sysconfigs; insert tableName=mpay_sysconfigs; sql', '', NULL, '3.8.2', NULL, NULL, '3475081559');
INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('156-feat-enable-creditor-limit-get-group-account-limit-procedure', 'ANAS', './scripts/core-jo/shared/156-feat-enable-creditor-limit.xml', '2024-08-28 14:57:06.966', 962, 'EXECUTED', '8:891f69f56bd6e06da615140ba778f831', 'sqlFile', '', NULL, '3.8.2', NULL, NULL, '4846224977');
INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('156-feat-enable-creditor-limit-update-account-limit-procedure', 'ANAS', './scripts/core-jo/shared/156-feat-enable-creditor-limit.xml', '2024-08-28 14:57:07.004', 963, 'EXECUTED', '8:b3edb542d31e83391149c593eb468ff9', 'sqlFile', '', NULL, '3.8.2', NULL, NULL, '4846224977');
INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('156-feat-enable-creditor-limit-modify-existing-constraint', 'ANAS', './scripts/core-jo/shared/156-feat-enable-creditor-limit.xml', '2024-08-28 14:57:07.029', 964, 'EXECUTED', '8:d08ec17693a1d04d65344040146309d1', 'dropUniqueConstraint constraintName=uk_2l7uh0sg0oybs2dfu9slgpdi9, tableName=MPAY_CLIENTSLIMITS; addUniqueConstraint constraintName=uk_2l7uh0sg0oybs2dfu9slgpdi9, tableName=MPAY_CLIENTSLIMITS', '', NULL, '3.8.2', NULL, NULL, '4846224977');
INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('20241027-01-addisReadColumnForNotificationsTable', 'Tuqa Abu-Matar', './scripts/core-jo/shared/mportal/application-data.xml', '2024-11-24 15:44:46.353', 1003, 'EXECUTED', '8:6eae80374861e197b960d43e27152c3c', 'addColumn tableName=mpay_notifications; update tableName=mpay_notifications', '', NULL, '3.8.2', NULL, NULL, '2452284893');
INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('169-add-reservedBalance-column-to-accounts', 'ANAS-ABD', './scripts/core-jo/shared/169-reserved-balance-ddl.xml', '2025-02-11 17:22:08.787', 1035, 'EXECUTED', '8:bf5c0be49715e86b8add2a687528f069', 'addColumn tableName=MPAY_ACCOUNTS; addColumn tableName=MPAY_TRANSACTIONS; addColumn tableName=MPAY_ENDPOINTOPERATIONS', '', NULL, '3.8.2', NULL, NULL, '9283728337');
INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('169-add-jv-type-for-reserved', 'ANAS-ABD', './scripts/core-jo/shared/169-reserved-balance-ddl.xml', '2025-02-11 17:22:08.938', 1036, 'EXECUTED', '8:faa318071e99ab82bab42f7a4c5bea1a', 'sql', '', NULL, '3.8.2', NULL, NULL, '9283728337');
INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('169-add-postReservedJournalVoucher-storedProcedure', 'ANAS-ABD', './scripts/core-jo/shared/169-reserved-balance-ddl.xml', '2025-02-11 17:22:08.943', 1037, 'EXECUTED', '8:2d581313b30ea92bf67e6c2b6dcaa83a', 'createProcedure', '', NULL, '3.8.2', NULL, NULL, '9283728337');
INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('169-1-remove-reservedBalance-postgres', 'MAJED', './scripts/core-jo/shared/169-reserved-balance-ddl.xml', '2025-03-25 16:47:07.960', 1071, 'EXECUTED', '8:fdd08d4418c1b9a64c8349e0bdd6fe0a', 'dropColumn columnName=RESERVEDBALANCE, tableName=MPAY_ACCOUNTS', '', NULL, '3.8.2', NULL, NULL, '2910427528');
INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('169-2-remove-reservedAmount-postgres', 'MAJED', './scripts/core-jo/shared/169-reserved-balance-ddl.xml', '2025-03-25 16:47:08.063', 1072, 'EXECUTED', '8:e4fa02d579336061934700759ad90401', 'dropColumn columnName=RESERVEDAMOUNT, tableName=MPAY_TRANSACTIONS', '', NULL, '3.8.2', NULL, NULL, '2910427528');
INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('169-3-remove-enableReserveAmount-postgres', 'MAJED', './scripts/core-jo/shared/169-reserved-balance-ddl.xml', '2025-03-25 16:47:08.092', 1073, 'EXECUTED', '8:a62f9bfb26aacf613f7ff38cfba70144', 'dropColumn columnName=ENABLERESERVEAMOUNT, tableName=MPAY_ENDPOINTOPERATIONS', '', NULL, '3.8.2', NULL, NULL, '2910427528');
INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('169-4-add-columns-new-required-cols', 'MAJED', './scripts/core-jo/shared/169-reserved-balance-ddl.xml', '2025-03-25 16:47:08.104', 1074, 'EXECUTED', '8:99505eab9defe39ec88b57e8ccdc8096', 'addColumn tableName=MPAY_ACCOUNTS; addColumn tableName=MPAY_TRANSACTIONS; addColumn tableName=MPAY_ENDPOINTOPERATIONS', '', NULL, '3.8.2', NULL, NULL, '2910427528');
INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('169-add-postReservedJournalVoucher-storedProcedure-v2', 'MAJED', './scripts/core-jo/shared/169-reserved-balance-ddl.xml', '2025-03-25 16:47:08.108', 1075, 'EXECUTED', '8:cf2f22c0537f9b450cfc2a0f5b8ce658', 'createProcedure', '', NULL, '3.8.2', NULL, NULL, '2910427528');
INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('2025072701-add-levelsixpurposes', 'MPAY', './scripts/core-jo/shared/190-feat-ttc-1670-migration-script-for-ttc.xml', '2025-08-12 13:11:39.941', 1139, 'EXECUTED', '8:7736a3d3e5d148f4ac0e52bb3ad82d12', 'sql; insert tableName=mpay_levelsixpurposes; insert tableName=mpay_levelsixpurposes; insert tableName=mpay_levelsixpurposes; insert tableName=mpay_levelsixpurposes; insert tableName=mpay_levelsixpurposes; insert tableName=mpay_levelsixpurposes; in...', '', NULL, '3.8.2', NULL, NULL, '4993498307');
INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('2025072702-add-level-two-missing-items', 'MPAY', './scripts/core-jo/shared/190-feat-ttc-1670-migration-script-for-ttc.xml', '2025-08-12 13:11:39.960', 1140, 'EXECUTED', '8:5802de3e8bf84c1d45409549f98d422f', 'sql; insert tableName=mpay_leveltwopointofinitiation; insert tableName=mpay_leveltwopointofinitiation; sql', '', NULL, '3.8.2', NULL, NULL, '4993498307');
INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('190-ttc-1671-add-migration-script-levelsixpurposeid-to-cliq-purposes-postgressql', 'ps.ahmad.al-aghbar', './scripts/core-jo/shared/190-feat-ttc-1670-migration-script-for-ttc.xml', '2025-08-12 13:11:40.105', 1141, 'EXECUTED', '8:d61c0a973573d31f0c95e4a75ea5f46b', 'sql', '', NULL, '3.8.2', NULL, NULL, '4993498307');
INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('190-ttc-1673-add-migration-script-levelsixpurposeid-to-cliq-purposes-postgressql', 'ps.ahmad.al-aghbar', './scripts/core-jo/shared/190-feat-ttc-1670-migration-script-for-ttc.xml', '2025-08-12 13:11:40.121', 1142, 'EXECUTED', '8:cbf48eae7b1f411b45e90e5da07b1589', 'sql', '', NULL, '3.8.2', NULL, NULL, '4993498307');
INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('190-ttc-1673-add-migration-script-leveltwoinitiationid-to-message-types', 'ps.ahmad.al-aghbar', './scripts/core-jo/shared/190-feat-ttc-1670-migration-script-for-ttc.xml', '2025-08-12 13:11:40.133', 1143, 'EXECUTED', '8:561f59bce7d597d2365b7f63383e6642', 'sql', '', NULL, '3.8.2', NULL, NULL, '4993498307');
INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('190-ttc-1673-add-migration-script-mpay_levelsixmsgetypes-to-messagetypes-postgressql', 'ps.ahmad.al-aghbar', './scripts/core-jo/shared/190-feat-ttc-1670-migration-script-for-ttc.xml', '2025-08-12 13:11:40.149', 1144, 'EXECUTED', '8:feb712b7d3712f254e689b694396031a', 'sql', '', NULL, '3.8.2', NULL, NULL, '4993498307');
INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('update-reason-code-309-customer-unsuspend', 'bouanani-soufiane', './scripts/core-jo/shared/fix-update-invalid-reason-for-unsuspend-customer.xml', '2025-10-20 14:15:06.188', 1190, 'EXECUTED', '8:4cbf7487fab0379754ea504ba76a90a1', 'sql; sql', '', NULL, '3.8.2', NULL, NULL, '0958905715');
INSERT INTO databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('final-update-reason-code-309-postgres-compatible', 'bouanani-soufiane', './scripts/core-jo/shared/fix-update-invalid-reason-for-unsuspend-customer.xml', '2025-10-20 14:15:06.215', 1191, 'EXECUTED', '8:f62be98f06f9d75c1f325716a3f5eb10', 'sql; sql', '', NULL, '3.8.2', NULL, NULL, '0958905715');


--POST RELEASE 1.50.0

INSERT INTO mpayuat.databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('204-rename-mpay_amlprocessingStatuses', 'Ahmad', './scripts/core-jo/shared/203-feat-create-remittance-processing-status.xml', '2025-11-11 12:52:30.093', 1209, 'EXECUTED', '8:3328c88ab630a885b97b7e7a722e340d', 'renameTable newTableName=mpay_amlprocessingstatuses, oldTableName=mpay_amlprocessingStatuses', '', NULL, '3.8.2', NULL, NULL, '2854749349');

INSERT INTO mpayuat.databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('99-feat-490-create-merchant-category-code-view-postgres', 'Suhaib', './scripts/dinarak/99-feat-490-create-merchant-category-code-view.xml', '2025-11-18 12:50:38.101', 1201, 'EXECUTED', '', 'sql', '', NULL, '3.8.2', NULL, NULL, '3470236761');

INSERT INTO mpayuat.databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('update-workflow-and-status-in-message-types-postgres', 'tuqa (generated)', './scripts/dinarak/95-update-meps-messagetypes-status.xml', '2025-11-30 14:23:59.861', 1215, 'EXECUTED', '8:6a112cda3dbb2af42fae75173cf71a32', 'sql', '', NULL, '3.8.2', NULL, NULL, '4501778652');

INSERT INTO mpayuat.databasechangelog
(id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, "comments", tag, liquibase, contexts, labels, deployment_id)
VALUES('99-feat-490-add-view-to-business-role-postgres', 'Suhaib', './scripts/dinarak/99-feat-490-create-merchant-category-code-view.xml', '2025-11-18 12:50:38.160', 1203, 'EXECUTED', '', 'sql', '', NULL, '3.8.2', NULL, NULL, '3470236761');



