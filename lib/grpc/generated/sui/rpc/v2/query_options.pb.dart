// This is a generated file - do not edit.
//
// Generated from sui/rpc/v2/query_options.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'query_options.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'query_options.pbenum.dart';

/// Cursor-bounded query options.
///
/// `after` and `before` are canonical ledger-position bounds, not
/// ordering-relative cursors. `after` always excludes items at or below that
/// cursor, and `before` always excludes items at or above that cursor. Ordering
/// only controls the order of returned items within the resulting open interval.
///
/// When a request also specifies a checkpoint range, cursor bounds and
/// checkpoint bounds compose by intersection: results come only from ledger
/// positions inside both. Checkpoint bounds are likewise canonical and
/// ordering-independent.
///
/// For example, with `after = A`, `before = B`, `ordering = DESCENDING`, and
/// `limit = N`, the response contains up to N matching items in descending
/// order from the interval `(A, B)`. If the response ends with
/// `QUERY_END_REASON_ITEM_LIMIT`, resume by keeping `after = A` and setting
/// `before` to the last `Watermark.cursor` received. That cursor is the
/// lowest position reached in ledger order, so it becomes the next exclusive
/// upper bound.
class QueryOptions extends $pb.GeneratedMessage {
  factory QueryOptions({
    $core.int? limit,
    $core.List<$core.int>? after,
    $core.List<$core.int>? before,
    Ordering? ordering,
  }) {
    final result = create();
    if (limit != null) result.limit = limit;
    if (after != null) result.after = after;
    if (before != null) result.before = before;
    if (ordering != null) result.ordering = ordering;
    return result;
  }

  QueryOptions._();

  factory QueryOptions.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory QueryOptions.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'QueryOptions',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'sui.rpc.v2'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'limit', fieldType: $pb.PbFieldType.OU3)
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'after', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'before', $pb.PbFieldType.OY)
    ..aE<Ordering>(4, _omitFieldNames ? '' : 'ordering',
        enumValues: Ordering.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QueryOptions clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QueryOptions copyWith(void Function(QueryOptions) updates) =>
      super.copyWith((message) => updates(message as QueryOptions))
          as QueryOptions;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static QueryOptions create() => QueryOptions._();
  @$core.override
  QueryOptions createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static QueryOptions getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<QueryOptions>(create);
  static QueryOptions? _defaultInstance;

  /// The maximum number of items to return. Each method applies its own default
  /// and maximum. QueryEnd does not count against this limit.
  @$pb.TagNumber(1)
  $core.int get limit => $_getIZ(0);
  @$pb.TagNumber(1)
  set limit($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLimit() => $_has(0);
  @$pb.TagNumber(1)
  void clearLimit() => $_clearField(1);

  /// Opaque exclusive lower bound. Results must be strictly after this cursor in
  /// canonical ledger order.
  @$pb.TagNumber(2)
  $core.List<$core.int> get after => $_getN(1);
  @$pb.TagNumber(2)
  set after($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAfter() => $_has(1);
  @$pb.TagNumber(2)
  void clearAfter() => $_clearField(2);

  /// Opaque exclusive upper bound. Results must be strictly before this cursor
  /// in canonical ledger order.
  @$pb.TagNumber(3)
  $core.List<$core.int> get before => $_getN(2);
  @$pb.TagNumber(3)
  set before($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBefore() => $_has(2);
  @$pb.TagNumber(3)
  void clearBefore() => $_clearField(3);

  /// Ordering for returned results. Defaults to ASCENDING.
  ///
  /// Ordering only controls the order of results within the bounded interval;
  /// cursor bounds keep the same meaning for ascending and descending reads.
  @$pb.TagNumber(4)
  Ordering get ordering => $_getN(3);
  @$pb.TagNumber(4)
  set ordering(Ordering value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasOrdering() => $_has(3);
  @$pb.TagNumber(4)
  void clearOrdering() => $_clearField(4);
}

/// A point in ledger order: the boundary between the items whose keys sort
/// below this position and the items whose keys sort at or above it.
///
/// An item's key is (`sequence_number`) for a `Checkpoint`, (`checkpoint`,
/// `transaction_index`) for an `ExecutedTransaction`, and (`checkpoint`,
/// `transaction_index`, `event_index`) for an `Event`. Keys and positions sort
/// lexicographically, with unset fields counting as 0.
///
/// An index past the last transaction of a checkpoint, or past the last event of
/// a transaction, names the start of the next one, so different positions can
/// name the same boundary: after the last of checkpoint `c`'s `n` transactions,
/// both (`c`, `n`) and (`c + 1`, 0) name the start of checkpoint `c + 1`.
/// Sorting never contradicts ledger order: a position that sorts below another
/// is at or before it. Use comparisons to drop what is behind, and never assume
/// that positions that differ name different boundaries.
///
/// To bound a request at a position: as its start, set `start_checkpoint` to
/// `checkpoint` and, when either index is nonzero, the start index fields to
/// both indexes, including one that is 0 (`start_transaction_index`, plus
/// `start_event_index` for events). As its end, set `end_checkpoint` to
/// `checkpoint` when both indexes are 0; otherwise set `end_checkpoint` to
/// `checkpoint + 1` and the end index fields to both indexes
/// (`end_transaction_index`, plus `end_event_index` for events). Checkpoint
/// positions carry only `checkpoint`, so they set only `start_checkpoint` or
/// `end_checkpoint`.
class LedgerPosition extends $pb.GeneratedMessage {
  factory LedgerPosition({
    $fixnum.Int64? checkpoint,
    $fixnum.Int64? transactionIndex,
    $core.int? eventIndex,
  }) {
    final result = create();
    if (checkpoint != null) result.checkpoint = checkpoint;
    if (transactionIndex != null) result.transactionIndex = transactionIndex;
    if (eventIndex != null) result.eventIndex = eventIndex;
    return result;
  }

  LedgerPosition._();

  factory LedgerPosition.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LedgerPosition.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LedgerPosition',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'sui.rpc.v2'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'checkpoint', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'transactionIndex', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aI(3, _omitFieldNames ? '' : 'eventIndex', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LedgerPosition clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LedgerPosition copyWith(void Function(LedgerPosition) updates) =>
      super.copyWith((message) => updates(message as LedgerPosition))
          as LedgerPosition;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LedgerPosition create() => LedgerPosition._();
  @$core.override
  LedgerPosition createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LedgerPosition getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LedgerPosition>(create);
  static LedgerPosition? _defaultInstance;

  /// Checkpoint sequence number.
  @$pb.TagNumber(1)
  $fixnum.Int64 get checkpoint => $_getI64(0);
  @$pb.TagNumber(1)
  set checkpoint($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCheckpoint() => $_has(0);
  @$pb.TagNumber(1)
  void clearCheckpoint() => $_clearField(1);

  /// Zero-based position of a transaction within `checkpoint`.
  @$pb.TagNumber(2)
  $fixnum.Int64 get transactionIndex => $_getI64(1);
  @$pb.TagNumber(2)
  set transactionIndex($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTransactionIndex() => $_has(1);
  @$pb.TagNumber(2)
  void clearTransactionIndex() => $_clearField(2);

  /// Zero-based index of an event within its transaction's event list. Event
  /// streams only.
  @$pb.TagNumber(3)
  $core.int get eventIndex => $_getIZ(2);
  @$pb.TagNumber(3)
  set eventIndex($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEventIndex() => $_has(2);
  @$pb.TagNumber(3)
  void clearEventIndex() => $_clearField(3);
}

/// Progress of a scan, carried on every response frame, whether or not the
/// frame delivers a matching item. Watermarks never regress in the requested
/// ordering, but consecutive frames may carry the same watermark when
/// additional work does not advance the safe resume frontier.
///
/// A watermark has two parts:
///
/// - The resume point, in two forms: `cursor`, opaque, for the server, and
///   `cursor_position`, in ledger coordinates, for clients to order frames and
///   drop duplicates.
/// - Coverage: `checkpoint`, the boundary checkpoint the scan has proven fully
///   covered. It trails the resume point.
///
/// To continue in the same direction, set the request's start (ascending) or
/// end (descending) at `cursor_position`. To read in the other direction, set
/// the other bound at `cursor_position` from a frame without an item; from a
/// frame with an item, start a page after the item at its key with the finest
/// index incremented, or end a page before it at its key. In both cases pass
/// `cursor` as `options.after` with a start and as `options.before` with an
/// end.
class Watermark extends $pb.GeneratedMessage {
  factory Watermark({
    $core.List<$core.int>? cursor,
    $fixnum.Int64? checkpoint,
    LedgerPosition? cursorPosition,
  }) {
    final result = create();
    if (cursor != null) result.cursor = cursor;
    if (checkpoint != null) result.checkpoint = checkpoint;
    if (cursorPosition != null) result.cursorPosition = cursorPosition;
    return result;
  }

  Watermark._();

  factory Watermark.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Watermark.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Watermark',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'sui.rpc.v2'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'cursor', $pb.PbFieldType.OY)
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'checkpoint', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<LedgerPosition>(4, _omitFieldNames ? '' : 'cursorPosition',
        subBuilder: LedgerPosition.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Watermark clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Watermark copyWith(void Function(Watermark) updates) =>
      super.copyWith((message) => updates(message as Watermark)) as Watermark;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Watermark create() => Watermark._();
  @$core.override
  Watermark createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Watermark getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Watermark>(create);
  static Watermark? _defaultInstance;

  /// Opaque cursor at the resume point. Set on every watermark. Use as
  /// `options.after` (ascending) or `options.before` (descending) on the next
  /// request to resume from here. The most recently received cursor is always
  /// the safe resume point.
  ///
  /// Pass cursors back unchanged; never compare or inspect them. Cursors that
  /// differ can name the same point, and their encoding may change.
  @$pb.TagNumber(1)
  $core.List<$core.int> get cursor => $_getN(0);
  @$pb.TagNumber(1)
  set cursor($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCursor() => $_has(0);
  @$pb.TagNumber(1)
  void clearCursor() => $_clearField(1);

  /// The inclusive boundary checkpoint that the scan has fully covered within
  /// the request's effective interval, in the request's ordering direction: an
  /// ascending scan has emitted every matching item in the interval at
  /// checkpoints `<= checkpoint` (strictly greater ones may still hold
  /// matches); a descending scan has emitted every matching item in the
  /// interval at checkpoints `>= checkpoint`. This boundary never regresses in
  /// the scan direction, but it may repeat while the cursor advances.
  ///
  /// Unset until the scan's first checkpoint is fully covered. For example, a
  /// scan resumed from a cursor that lands mid-checkpoint leaves this unset
  /// until the next checkpoint boundary in the scan direction is fully covered.
  /// A watermark still has a valid resume cursor while this field is unset.
  @$pb.TagNumber(2)
  $fixnum.Int64 get checkpoint => $_getI64(1);
  @$pb.TagNumber(2)
  set checkpoint($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCheckpoint() => $_has(1);
  @$pb.TagNumber(2)
  void clearCheckpoint() => $_clearField(2);

  /// The resume point in ledger coordinates. Set on every watermark by servers
  /// that support it.
  ///
  /// Ascending, every match from the request's start up to (excluding)
  /// `cursor_position` has been delivered. Descending, every match from
  /// `cursor_position` up to (excluding) the request's end has been delivered.
  ///
  /// On a frame that carries an item, ascending, it is the boundary just past
  /// the item, so it is not the item's own key: it is that key with its finest
  /// index incremented (`event_index` for events, `transaction_index` for
  /// transactions, `checkpoint` for checkpoints). Descending, it is the boundary
  /// just before the item, which is the item's key.
  ///
  /// It never moves before the request's start (ascending) or past its end
  /// (descending), so an ascending request that starts beyond what the server
  /// has indexed gets its start echoed back: the resume point says where the
  /// client is, not where the ledger is. `cursor` may then name an earlier
  /// point; bounds intersect, so resuming with both starts at
  /// `cursor_position`.
  @$pb.TagNumber(4)
  LedgerPosition get cursorPosition => $_getN(2);
  @$pb.TagNumber(4)
  set cursorPosition(LedgerPosition value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasCursorPosition() => $_has(2);
  @$pb.TagNumber(4)
  void clearCursorPosition() => $_clearField(4);
  @$pb.TagNumber(4)
  LedgerPosition ensureCursorPosition() => $_ensure(2);
}

/// Marker for the final frame of a successful query stream. Every successful
/// stream sets `QueryEnd` on exactly one frame, after which no further frames
/// are sent. That frame always carries the final watermark. For `ItemLimit`, it
/// also carries the final matching item; for every other reason it carries no
/// item. A ScanLimit terminal watermark may repeat the previous frame's cursor
/// when its authoritative scan frontier was already emitted; this does not
/// repeat an item.
///
/// A stream that fails or is cancelled terminates with a gRPC status and does
/// not send `QueryEnd`.
class QueryEnd extends $pb.GeneratedMessage {
  factory QueryEnd({
    QueryEndReason? reason,
  }) {
    final result = create();
    if (reason != null) result.reason = reason;
    return result;
  }

  QueryEnd._();

  factory QueryEnd.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory QueryEnd.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'QueryEnd',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'sui.rpc.v2'),
      createEmptyInstance: create)
    ..aE<QueryEndReason>(1, _omitFieldNames ? '' : 'reason',
        enumValues: QueryEndReason.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QueryEnd clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QueryEnd copyWith(void Function(QueryEnd) updates) =>
      super.copyWith((message) => updates(message as QueryEnd)) as QueryEnd;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static QueryEnd create() => QueryEnd._();
  @$core.override
  QueryEnd createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static QueryEnd getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QueryEnd>(create);
  static QueryEnd? _defaultInstance;

  /// Reason this response stopped.
  @$pb.TagNumber(1)
  QueryEndReason get reason => $_getN(0);
  @$pb.TagNumber(1)
  set reason(QueryEndReason value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasReason() => $_has(0);
  @$pb.TagNumber(1)
  void clearReason() => $_clearField(1);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
