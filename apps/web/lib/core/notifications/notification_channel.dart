bool isCriticalLevel(String? level) => level == 'CRITICAL';

String channelForLevel(String? level) =>
    isCriticalLevel(level) ? 'critical' : 'default';
