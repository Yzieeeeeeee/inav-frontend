import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  NOTIFICATION MODEL
// ─────────────────────────────────────────────────────────────────────────────
enum NotifType { success, payment, reminder, alert, info }

class NotifItem {
  final String id;
  final String title;
  final String body;
  final String timeLabel;
  final NotifType type;
  bool isRead;

  NotifItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timeLabel,
    required this.type,
    this.isRead = false,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
//  SAMPLE DATA
// ─────────────────────────────────────────────────────────────────────────────
final List<NotifItem> _sampleNotifs = [
  NotifItem(
    id: 'N001',
    title: 'EMI Payment Successful',
    body: 'Your EMI of \$788.50 for Personal Loan (****4582) has been successfully processed.',
    timeLabel: 'Just now',
    type: NotifType.success,
  ),
  NotifItem(
    id: 'N002',
    title: 'EMI Due Reminder',
    body: 'Your Home Loan EMI of \$2,340.00 is due in 3 days on Oct 10, 2025. Ensure sufficient balance.',
    timeLabel: '2h ago',
    type: NotifType.reminder,
  ),
  NotifItem(
    id: 'N003',
    title: 'Overdue Payment Alert',
    body: 'Your Business Loan (****9903) payment is overdue. Pay immediately to avoid penalty charges.',
    timeLabel: '5h ago',
    type: NotifType.alert,
  ),
  NotifItem(
    id: 'N004',
    title: 'New Loan Offer Available',
    body: 'You are eligible for a Gold Loan up to \$50,000 at 8.2% p.a. Tap to view offer details.',
    timeLabel: 'Yesterday',
    type: NotifType.info,
    isRead: true,
  ),
  NotifItem(
    id: 'N005',
    title: 'Car Loan Almost Cleared',
    body: 'Great news! Only 10 EMIs remaining on your Car Loan (****3310). You\'re almost debt-free!',
    timeLabel: 'Yesterday',
    type: NotifType.success,
    isRead: true,
  ),
  NotifItem(
    id: 'N006',
    title: 'Statement Generated',
    body: 'Your September 2025 loan statement is ready. Download it from Payment History.',
    timeLabel: '2 days ago',
    type: NotifType.payment,
    isRead: true,
  ),
  NotifItem(
    id: 'N007',
    title: 'Interest Rate Update',
    body: 'The RBI has revised base rates. Your Home Loan interest rate will be updated from Nov 1, 2025.',
    timeLabel: '3 days ago',
    type: NotifType.alert,
    isRead: true,
  ),
  NotifItem(
    id: 'N008',
    title: 'Education Loan Disbursed',
    body: 'Your Education Loan of \$40,000 has been approved and will be disbursed within 2 business days.',
    timeLabel: '1 week ago',
    type: NotifType.payment,
    isRead: true,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
//  NOTIFICATIONS PAGE
// ─────────────────────────────────────────────────────────────────────────────
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  static const _blue      = Color(0xFF1D4ED8);
  static const _blueDeep  = Color(0xFF1239A8);
  static const _bg        = Color(0xFFF8FAFC);
  static const _textMid   = Color(0xFF475569);
  static const _textLight = Color(0xFF94A3B8);
  static const double _navBarH = 82.0;

  final List<NotifItem> _notifs = List.from(_sampleNotifs);
  String _filter = 'All';
  final _filters = ['All', 'Unread', 'Payments', 'Alerts'];

  int get _unreadCount => _notifs.where((n) => !n.isRead).length;

  List<NotifItem> get _filtered => _notifs.where((n) {
    return switch (_filter) {
      'Unread'   => !n.isRead,
      'Payments' => n.type == NotifType.payment || n.type == NotifType.success,
      'Alerts'   => n.type == NotifType.alert   || n.type == NotifType.reminder,
      _          => true,
    };
  }).toList();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  void _markAllRead() {
    setState(() {
      for (final n in _notifs) n.isRead = true;
    });
    _snack('All notifications marked as read', const Color(0xFF10B981));
  }

  void _deleteItem(NotifItem item) {
    setState(() => _notifs.remove(item));
    _snack('Notification removed', _textMid);
  }

  void _clearAll() {
    setState(() => _notifs.clear());
    _snack('All notifications cleared', _textMid);
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final mq          = MediaQuery.of(context);
    final bottomInset = mq.padding.bottom;
    final items       = _filtered;

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // Gradient header blob
          Container(
            height: mq.padding.top + 200,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_blue, _blueDeep],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft:  Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
            ),
          ),
          Positioned(top: -50, right: -50,
              child: _Ring(size: 210, opacity: 0.07)),
          Positioned(top:  30, left: -60,
              child: _Ring(size: 160, opacity: 0.05)),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [

              // ── AppBar ───────────────────────────────────────────────────
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 20),
                  onPressed: () => context.push("/navig"),
                ),
                title: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Text('Notifications',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18)),
                  if (_unreadCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('$_unreadCount',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800)),
                    ),
                  ],
                ]),
                centerTitle: true,
                actions: [
                  if (_notifs.isNotEmpty)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded,
                          color: Colors.white),
                      color: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      onSelected: (v) {
                        if (v == 'markAll') _markAllRead();
                        if (v == 'clear')   _clearAll();
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'markAll',
                          child: Row(children: [
                            Icon(Icons.done_all_rounded,
                                size: 18, color: Color(0xFF1D4ED8)),
                            SizedBox(width: 10),
                            Text('Mark all as read',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                          ]),
                        ),
                        const PopupMenuItem(
                          value: 'clear',
                          child: Row(children: [
                            Icon(Icons.delete_sweep_rounded,
                                size: 18, color: Color(0xFFEF4444)),
                            SizedBox(width: 10),
                            Text('Clear all',
                                style: TextStyle(
                                    color: Color(0xFFEF4444),
                                    fontWeight: FontWeight.w600)),
                          ]),
                        ),
                      ],
                    ),
                ],
              ),

              // ── Summary card ─────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                  child: _SummaryCard(
                    total:     _notifs.length,
                    unread:    _unreadCount,
                    onMarkAll: _unreadCount > 0 ? _markAllRead : null,
                  ),
                ),
              ),

              // ── Filter chips ─────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 0, 6),
                  child: SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filters.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final label  = _filters[i];
                        final active = _filter == label;
                        return GestureDetector(
                          onTap: () => setState(() => _filter = label),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeInOutCubic,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: active ? _blue : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: active
                                      ? _blue.withOpacity(0.28)
                                      : Colors.black.withOpacity(0.05),
                                  blurRadius: active ? 10 : 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Text(label,
                                    style: TextStyle(
                                        color: active ? Colors.white : _textMid,
                                        fontWeight: active
                                            ? FontWeight.w700 : FontWeight.w500,
                                        fontSize: 13)),
                                if (label == 'Unread' && _unreadCount > 0) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: active
                                          ? Colors.white.withOpacity(0.25)
                                          : const Color(0xFFEF4444),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text('$_unreadCount',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800)),
                                  ),
                                ],
                              ]),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Count label
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
                  child: Text(
                    '${items.length} notification${items.length != 1 ? 's' : ''}',
                    style: const TextStyle(
                        color: _textLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),

              // ── Notification list ────────────────────────────────────────
              items.isEmpty
                  ? SliverFillRemaining(child: _EmptyState())
                  : SliverPadding(
                padding: EdgeInsets.fromLTRB(
                    18, 0, 18, _navBarH + bottomInset + 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _NotifCard(
                        item:     items[i],
                        onTap:    () => setState(() => items[i].isRead = true),
                        onDelete: () => _deleteItem(items[i]),
                      ),
                    ),
                    childCount: items.length,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SUMMARY CARD
// ─────────────────────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final int total, unread;
  final VoidCallback? onMarkAll;
  const _SummaryCard({
    required this.total, required this.unread, required this.onMarkAll});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D4ED8).withOpacity(0.10),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(children: [
        // Bell icon with red dot
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF1D4ED8).withOpacity(0.08),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Stack(alignment: Alignment.center, children: [
            const Icon(Icons.notifications_rounded,
                color: Color(0xFF1D4ED8), size: 26),
            if (unread > 0)
              Positioned(
                top: 10, right: 10,
                child: Container(
                  width: 9, height: 9,
                  decoration: const BoxDecoration(
                      color: Color(0xFFEF4444), shape: BoxShape.circle),
                ),
              ),
          ]),
        ),
        const SizedBox(width: 14),

        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$total Notifications',
              style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w800,
                  fontSize: 15)),
          const SizedBox(height: 3),
          Text(
            unread > 0 ? '$unread unread messages' : 'All caught up! ✓',
            style: TextStyle(
                color: unread > 0
                    ? const Color(0xFF1D4ED8)
                    : const Color(0xFF10B981),
                fontSize: 12,
                fontWeight: FontWeight.w600),
          ),
        ])),

        if (onMarkAll != null)
          GestureDetector(
            onTap: onMarkAll,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1D4ED8).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('Mark all read',
                  style: TextStyle(
                      color: Color(0xFF1D4ED8),
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ),
          ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  NOTIFICATION CARD  — swipe left to delete
// ─────────────────────────────────────────────────────────────────────────────
class _NotifCard extends StatelessWidget {
  final NotifItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _NotifCard({required this.item, required this.onTap, required this.onDelete});

  _Meta _meta(NotifType t) => switch (t) {
    NotifType.success  => _Meta(Icons.check_circle_rounded,
        const Color(0xFF10B981), const Color(0xFFDCFCE7)),
    NotifType.payment  => _Meta(Icons.payments_rounded,
        const Color(0xFF1D4ED8), const Color(0xFFDBEAFE)),
    NotifType.reminder => _Meta(Icons.schedule_rounded,
        const Color(0xFFF59E0B), const Color(0xFFFEF3C7)),
    NotifType.alert    => _Meta(Icons.warning_amber_rounded,
        const Color(0xFFEF4444), const Color(0xFFFEE2E2)),
    NotifType.info     => _Meta(Icons.info_rounded,
        const Color(0xFF7C3AED), const Color(0xFFEDE9FE)),
  };

  @override
  Widget build(BuildContext context) {
    final m = _meta(item.type);
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 22),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444).withOpacity(0.10),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.delete_rounded, color: Color(0xFFEF4444), size: 26),
          SizedBox(height: 4),
          Text('Delete', style: TextStyle(
              color: Color(0xFFEF4444), fontSize: 11, fontWeight: FontWeight.w700)),
        ]),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: item.isRead ? Colors.white : const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: item.isRead
                  ? const Color(0xFFF1F5F9)
                  : const Color(0xFF1D4ED8).withOpacity(0.20),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: item.isRead
                    ? Colors.black.withOpacity(0.03)
                    : const Color(0xFF1D4ED8).withOpacity(0.07),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Icon badge
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                  color: m.bg, borderRadius: BorderRadius.circular(14)),
              child: Icon(m.icon, color: m.color, size: 22),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(item.title,
                          style: TextStyle(
                              color: const Color(0xFF0F172A),
                              fontWeight: item.isRead
                                  ? FontWeight.w600 : FontWeight.w800,
                              fontSize: 13.5,
                              letterSpacing: -0.1),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    Text(item.timeLabel,
                        style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 5),
                Text(item.body,
                    style: TextStyle(
                        color: item.isRead
                            ? const Color(0xFF64748B)
                            : const Color(0xFF475569),
                        fontSize: 12.5,
                        height: 1.5),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ]),
            ),

            // Unread dot
            if (!item.isRead)
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Container(
                  width: 9, height: 9,
                  decoration: const BoxDecoration(
                      color: Color(0xFF1D4ED8), shape: BoxShape.circle),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  EMPTY STATE
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 88, height: 88,
          decoration: BoxDecoration(
            color: const Color(0xFF1D4ED8).withOpacity(0.07),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.notifications_off_rounded,
              color: Color(0xFF94A3B8), size: 40),
        ),
        const SizedBox(height: 18),
        const Text('All caught up!',
            style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 20,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        const Text('No notifications here.',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────────────────────────────────────
class _Meta {
  final IconData icon;
  final Color color, bg;
  const _Meta(this.icon, this.color, this.bg);
}

class _Ring extends StatelessWidget {
  final double size, opacity;
  const _Ring({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) => Container(
      width: size, height: size,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(opacity)));
}