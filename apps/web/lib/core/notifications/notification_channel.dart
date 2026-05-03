bool isCriticalLevel(String? level) => level == 'CRITICAL';

String channelForLevel(String? level) =>
    isCriticalLevel(level) ? 'critical' : 'default';

String channelNameForLevel(String? level) =>
    isCriticalLevel(level) ? 'Alertas Críticos NOTIF' : 'Alertas NOTIF';
