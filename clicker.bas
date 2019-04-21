_MOUSEHIDE
_TITLE "Clicker"

TYPE Object
    x AS INTEGER
    y AS INTEGER
    w AS INTEGER
    h AS INTEGER
    xv AS INTEGER
    yv AS INTEGER
    fg AS INTEGER
    bg AS INTEGER
    state AS _BYTE
END TYPE

DIM SHARED obj(1 TO 10) AS Object
DIM SHARED mouse(1 TO 8) AS STRING
DIM SHARED activeObjects AS INTEGER
DIM SHARED score AS LONG, level AS LONG

createObjects
createMouse

level = 1

DO
    pollMouse
    checkMouseAction

    COLOR , 0
    CLS
    updateObjects
    showObjects

    top$ = "Level:" + STR$(level) + "  *  Score:" + STR$(score)
    COLOR 15, 0
    _PRINTSTRING (1, 1), top$

    IF _MOUSEX > 0 AND _MOUSEY > 0 THEN
        showMouse
    END IF
    _DISPLAY
    limit = 60 * (level / 2)
    IF limit < 200 THEN _LIMIT limit
LOOP

SUB pollMouse
    WHILE _MOUSEINPUT: WEND
END SUB

SUB checkMouseAction STATIC
    IF _MOUSEBUTTON(1) THEN
        IF mouseDown = 0 THEN
            mouseDown = -1
        END IF
    ELSE
        IF mouseDown THEN
            mouseDown = 0
            destroyObject _MOUSEX, _MOUSEY
            IF activeObjects = 0 THEN
                PLAY "T120 L16 O3 E G C"
                createObjects
                level = level + 1
            END IF
        END IF
    END IF
END SUB

SUB createObjects
    RANDOMIZE TIMER
    FOR i = 1 TO UBOUND(obj)
        obj(i).x = _CEIL(RND * 70)
        obj(i).y = _CEIL(RND * 20)
        obj(i).w = 10
        obj(i).h = 5
        obj(i).xv = 1 - RND * 2
        obj(i).yv = 1 - RND * 2
        obj(i).fg = _CEIL(RND * 15)
        obj(i).bg = _CEIL(RND * 7)
        IF obj(i).bg = 0 THEN obj(i).bg = 1
        obj(i).state = -1
    NEXT
    activeObjects = UBOUND(obj)
END SUB

SUB destroyObject (x AS INTEGER, y AS INTEGER)
    FOR i = UBOUND(obj) TO 1 STEP -1
        IF x >= obj(i).x AND x <= obj(i).x + obj(i).w - 1 THEN
            IF y >= obj(i).y AND y <= obj(i).y + obj(i).h - 1 THEN
                IF obj(i).state THEN
                    FOR z = 1 TO 5
                        obj(i).x = obj(i).x - 2
                        obj(i).y = obj(i).y - 1
                        obj(i).w = obj(i).w + 4
                        obj(i).h = obj(i).h + 2
                        pollMouse
                        showObjects
                        showMouse
                        _DISPLAY
                        _LIMIT 30
                    NEXT
                    obj(i).state = 0
                    score = score + obj(i).bg
                    activeObjects = activeObjects - 1
                    EXIT FOR
                END IF
            END IF
        END IF
    NEXT
END SUB

SUB createMouse
    RESTORE mouseData
    i = 1
    DO
        READ a
        IF a = -1 THEN EXIT DO
        IF a = 0 THEN i = i + 1: _CONTINUE
        mouse(i) = mouse(i) + CHR$(a)
    LOOP

    mouseData:
    DATA 220,0
    DATA 219,219,220,0
    DATA 219,219,219,219,220,0
    DATA 219,219,219,219,219,219,220,0
    DATA 219,219,219,219,219,219,219,219,220,0
    DATA 219,219,219,219,219,219,223,223,223,223,0
    DATA 219,223,32,32,223,219,219,0
    DATA 32,32,32,32,32,32,219,219,0
    DATA -1
END SUB

SUB showObjects
    FOR i = 1 TO UBOUND(obj)
        IF obj(i).state = -1 THEN
            box obj(i).x, obj(i).y, obj(i).w, obj(i).h, obj(i).fg, obj(i).bg

            COLOR obj(i).fg, obj(i).bg
            _PRINTSTRING (obj(i).x + (obj(i).w \ 2), obj(i).y + obj(i).h \ 2), LTRIM$(STR$(obj(i).bg))
        END IF
    NEXT
END SUB

SUB updateObjects STATIC
    IF TIMER - lastUpdate! < .5 THEN EXIT SUB
    lastUpdate! = TIMER

    FOR i = 1 TO UBOUND(obj)
        IF obj(i).state = -1 THEN
            obj(i).x = obj(i).x + obj(i).xv
            IF obj(i).x < 1 OR obj(i).x + obj(i).w > _WIDTH THEN obj(i).xv = obj(i).xv * -1

            obj(i).y = obj(i).y + obj(i).yv
            IF obj(i).y < 1 OR obj(i).y + obj(i).h > _HEIGHT THEN obj(i).yv = obj(i).yv * -1
        END IF
    NEXT
END SUB

SUB showMouse
    FOR i = 1 TO 8
        IF (_MOUSEY + i) - 1 <= 25 THEN
            FOR j = _MOUSEX TO _MOUSEX + LEN(mouse(i)) - 1
                IF j > 80 THEN EXIT FOR
                m$ = MID$(mouse(i), (j - _MOUSEX) + 1, 1)
                IF m$ <> " " THEN
                    COLOR 15, SCREEN((_MOUSEY + i) - 1, j, 1) \ 16
                    _PRINTSTRING (j, (_MOUSEY + i) - 1), m$
                END IF
            NEXT
        END IF
    NEXT
END SUB

SUB box (x AS INTEGER, y AS INTEGER, w AS INTEGER, h AS INTEGER, fg AS INTEGER, bg AS INTEGER)
    prevFG = _DEFAULTCOLOR
    prevBG = _BACKGROUNDCOLOR
    COLOR fg, bg

    FOR i = x TO x + w - 1
        IF i < 1 OR i > _WIDTH THEN _CONTINUE
        FOR j = y TO y + h - 1
            IF j < 1 OR j > _HEIGHT THEN _CONTINUE
            IF (i = x OR i = x + w - 1) AND (j > y AND j < y + h - 1) THEN
                _PRINTSTRING (i, j), CHR$(186)
            ELSE
                IF j = y OR j = y + h - 1 AND (i > x AND i < x + w - 1) THEN
                    _PRINTSTRING (i, j), CHR$(205)
                ELSE
                    _PRINTSTRING (i, j), CHR$(32)
                END IF
            END IF
        NEXT
    NEXT

    IF x >= 1 AND x <= _WIDTH AND y >= 1 AND y <= _HEIGHT THEN _PRINTSTRING (x, y), CHR$(201)
    IF x + w - 1 >= 1 AND x + w - 1 <= _WIDTH AND y >= 1 AND y <= _HEIGHT THEN _PRINTSTRING (x + w - 1, y), CHR$(187)
    IF x >= 1 AND x <= _WIDTH AND y + h - 1 >= 1 AND y + h - 1 <= _HEIGHT THEN _PRINTSTRING (x, y + h - 1), CHR$(200)
    IF x + w - 1 >= 1 AND x + w - 1 <= _WIDTH AND y + h - 1 >= 1 AND y + h - 1 <= _HEIGHT THEN _PRINTSTRING (x + w - 1, y + h - 1), CHR$(188)

    COLOR prevFG, prevBG
END SUB
