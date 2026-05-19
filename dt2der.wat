(module

  (memory (export "memory") 1)

  (func $ymdhms2packed (export "ymdhms2packed")
    (param $year i32)
    (param $month i32)
    (param $day i32)
    (param $hour i32)
    (param $min i32)
    (param $sec i32)
    (param $us i32)
    (result i64)

    ;; compute the prefix
    ;; day 1 -> 0x8006
    ;; day 2 -> 0x8106
    ;; day 3 -> 0x8206
    ;; ...
    ;; day 31 -> 0x9e06
    local.get $day ;; 1-31
    i32.const 0x0000_001f
    i32.and
    i32.const 0x0000_007f
    i32.add
    i64.extend_i32_u
    i64.const 56
    i64.shl
    i64.const 0x0006_0000_0000_0000
    i64.or

    ;; compute the year part 1-8191
    local.get $year
    i32.const 0x0000_1fff
    i32.and
    i64.extend_i32_u
    i64.const 35
    i64.shl
    i64.or

    ;; compute the month part 1-12
    local.get $month
    i32.const 0x0000_000f
    i32.and
    i64.extend_i32_u
    i64.const 31
    i64.shl
    i64.or

    ;; compute the hour part 0-23
    local.get $hour
    i32.const 0x0000_001f
    i32.and
    i64.extend_i32_u
    i64.const 26
    i64.shl
    i64.or

    ;; compute the min part 0-59
    local.get $min
    i32.const 0x0000_003f
    i32.and
    i64.extend_i32_u
    i64.const 20
    i64.shl
    i64.or

    ;; compute the sec part 0-59
    local.get $sec
    i32.const 0x0000_003f
    i32.and
    i64.extend_i32_u
    i64.const 14
    i64.shl
    i64.or

    ;; compute the ms part 0.0 - 999.9(0us - 999,900us; 0-9999)
    local.get $us
    i32.const 0x0000_3fff
    i32.and
    i64.extend_i32_u
    i64.or
  )

  (func $packed2year (export "packed2year") (param $packed i64) (result i32)
    local.get $packed
    i64.const 35
    i64.shr_u
    i64.const 0x0000_0000_0000_1fff
    i64.and
    i32.wrap_i64
  )

  (func $packed2month (export "packed2month") (param $packed i64) (result i32)
    local.get $packed
    i64.const 31
    i64.shr_u
    i64.const 0x0000_0000_0000_000f
    i64.and
    i32.wrap_i64
  )

  ;; 0x8006 -> day 1
  ;; 0x8106 -> day 2
  ;; 0x8206 -> day 3
  ;; ...
  ;; 0x9e06 -> day 31
  (func $packed2day (export "packed2day") (param $packed i64) (result i32)
    local.get $packed
    i64.const 56
    i64.shr_u
    i64.const 0x0000_0000_0000_00ff
    i64.and
    i64.const 0x0000_0000_0000_007f
    i64.sub
    i32.wrap_i64
  )

  (func $packed2hour (export "packed2hour") (param $packed i64) (result i32)
    local.get $packed
    i64.const 26
    i64.shr_u
    i64.const 0x0000_0000_0000_001f
    i64.and
    i32.wrap_i64
  )

  (func $packed2min (export "packed2min") (param $packed i64) (result i32)
    local.get $packed
    i64.const 20
    i64.shr_u
    i64.const 0x0000_0000_0000_003f
    i64.and
    i32.wrap_i64
  )

  (func $packed2sec (export "packed2sec") (param $packed i64) (result i32)
    local.get $packed
    i64.const 14
    i64.shr_u
    i64.const 0x0000_0000_0000_003f
    i64.and
    i32.wrap_i64
  )

  (func $packed2us (export "packed2us") (param $packed i64) (result i32)
    local.get $packed
    i64.const 0x0000_0000_0000_3fff
    i64.and
    i64.const 100
    i64.mul
    i32.wrap_i64
  )

  (func $ymdhms2unpacked (export "ymdhms2unpacked")
    (param $year i32)
    (param $month i32)
    (param $day i32)
    (param $hour i32)
    (param $min i32)
    (param $sec i32)
    (param $us i32)

    ;; const prefix
    i32.const 0
    i32.const 0x02801730 ;; 0x3017_8002
    i32.store

    ;; year part(value only)
    i32.const 4
    local.get $year
    i32.const 0x0000_1fff
    i32.and
    i32.store16

    ;; month part
    ;; TL
    i32.const 6
    i32.const 0x0181 ;; 0x8101
    i32.store16
    ;; V
    i32.const 6
    local.get $month
    i32.const 0x0000_000f
    i32.and
    i32.store8 offset=2

    ;; day part
    ;; TL
    i32.const 9
    i32.const 0x0182 ;; 0x8201
    i32.store16
    ;; V
    i32.const 9
    local.get $day
    i32.const 0x0000_001f
    i32.and
    i32.store8 offset=2

    ;; hour part
    ;; TL
    i32.const 12
    i32.const 0x0183 ;; 0x8301
    i32.store16
    ;; V
    i32.const 12
    local.get $hour
    i32.const 0x0000_001f
    i32.and
    i32.store8 offset=2

    ;; min part
    ;; TL
    i32.const 15
    i32.const 0x0184 ;; 0x8401
    i32.store16
    ;; V
    i32.const 15
    local.get $min
    i32.const 0x0000_003f
    i32.and
    i32.store8 offset=2

    ;; sec part
    ;; TL
    i32.const 18
    i32.const 0x0185 ;; 0x8501
    i32.store16
    ;; V
    i32.const 18
    local.get $sec
    i32.const 0x0000_003f
    i32.and
    i32.store8 offset=2

    ;; us part
    ;; TL
    i32.const 21
    i32.const 0x0286 ;; 0x8601
    i32.store16
    ;; V
    i32.const 21
    local.get $us
    i32.const 0x0000_3fff
    i32.and
    i32.store16 offset=2
  )

)
