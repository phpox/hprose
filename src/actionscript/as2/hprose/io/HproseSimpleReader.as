﻿/**********************************************************\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: http://www.hprose.com/                 |
|                   http://www.hprose.net/                 |
|                   http://www.hprose.org/                 |
|                                                          |
\**********************************************************/
/**********************************************************\
 *                                                        *
 * HproseSimpleReader.as                                  *
 *                                                        *
 * hprose simple reader class for ActionScript 2.0.       *
 *                                                        *
 * LastModified: Dec 27, 2013                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

import hprose.common.HproseException;
import hprose.io.HproseClassManager;
import hprose.io.HproseStringInputStream;
import hprose.io.HproseRawReader;
import hprose.io.HproseTags;

class hprose.io.HproseSimpleReader extends HproseRawReader {
    private var classref:Array;

    public function HproseSimpleReader(stream:HproseStringInputStream) {
        super(stream);
        this.classref = [];
    }

    public function unserialize() {
        var tag = stream.getc();
        switch (tag) {
            case '0': return 0;
            case '1': return 1;
            case '2': return 2;
            case '3': return 3;
            case '4': return 4;
            case '5': return 5;
            case '6': return 6;
            case '7': return 7;
            case '8': return 8;
            case '9': return 9;
            case HproseTags.TagInteger: return readIntegerWithoutTag();
            case HproseTags.TagLong: return readLongWithoutTag();
            case HproseTags.TagDouble: return readDoubleWithoutTag();
            case HproseTags.TagNull: return null;
            case HproseTags.TagEmpty: return "";
            case HproseTags.TagTrue: return true;
            case HproseTags.TagFalse: return false;
            case HproseTags.TagNaN: return NaN;
            case HproseTags.TagInfinity: return readInfinityWithoutTag();
            case HproseTags.TagDate: return readDateWithoutTag();
            case HproseTags.TagTime: return readTimeWithoutTag();
            case HproseTags.TagUTF8Char: return stream.getc();
            case HproseTags.TagString: return readStringWithoutTag();
            case HproseTags.TagGuid: return readGuidWithoutTag();
            case HproseTags.TagList: return readListWithoutTag();
            case HproseTags.TagMap: return readMapWithoutTag();
            case HproseTags.TagClass: readClass(); return readObject();
            case HproseTags.TagObject: return readObjectWithoutTag();
            case HproseTags.TagRef: return readRef();
            case HproseTags.TagError: throw new HproseException(readString());
            default: unexpectedTag(tag);
        }
    }

    private function _checkTag(tag:String, expectTag:String):Void {
        if (tag != expectTag) unexpectedTag(tag, expectTag);
    }

    public function checkTag(expectTag:String):Void {
         _checkTag(stream.getc(), expectTag);
    }

    private function _checkTags(tag:String, expectTags:Array):String {
        if (expectTags.indexOf(tag) < 0) unexpectedTag(tag, expectTags.join(''));
        return tag;
    }

    public function checkTags(expectTags:Array):String {
        return _checkTags(stream.getc(), expectTags);
    }

    private function readInt(tag) {
        var s = stream.readuntil(tag);
        if (s.length == 0) return 0;
        return parseInt(s);
    }

    public function readIntegerWithoutTag():Number {
        return readInt(HproseTags.TagSemicolon);
    }

    public function readInteger():Number {
        var tag = stream.getc();
        switch (tag) {
            case '0': return 0;
            case '1': return 1;
            case '2': return 2;
            case '3': return 3;
            case '4': return 4;
            case '5': return 5;
            case '6': return 6;
            case '7': return 7;
            case '8': return 8;
            case '9': return 9;
            case HproseTags.TagInteger: return readIntegerWithoutTag();
            default: unexpectedTag(tag);
        }
    }

    public function readLongWithoutTag():String {
        return stream.readuntil(HproseTags.TagSemicolon);
    }

    public function readLong():String {
        var tag:String = stream.getc();
        switch (tag) {
            case '0':
            case '1':
            case '2':
            case '3':
            case '4':
            case '5':
            case '6':
            case '7':
            case '8':
            case '9': return tag;
            case HproseTags.TagInteger:
            case HproseTags.TagLong: return readLongWithoutTag();
            default: unexpectedTag(tag);
        }
    }

    public function readDoubleWithoutTag():Number {
        return parseFloat(stream.readuntil(HproseTags.TagSemicolon));
    }

    public function readDouble():Number {
        var tag = stream.getc();
        switch (tag) {
            case '0': return 0;
            case '1': return 1;
            case '2': return 2;
            case '3': return 3;
            case '4': return 4;
            case '5': return 5;
            case '6': return 6;
            case '7': return 7;
            case '8': return 8;
            case '9': return 9;
            case HproseTags.TagInteger:
            case HproseTags.TagLong:
            case HproseTags.TagDouble: return readDoubleWithoutTag();
            case HproseTags.TagNaN: return NaN;
            case HproseTags.TagInfinity: return readInfinityWithoutTag();
            default: unexpectedTag(tag);
        }
    }

    public function readNaN():Number {
        checkTag(HproseTags.TagNaN);
        return NaN;
    }

    public function readInfinityWithoutTag():Number {
        return ((stream.getc() == HproseTags.TagNeg) ? -Infinity : Infinity);
    }

    public function readInfinity():Number {
        checkTag(HproseTags.TagInfinity);
        return readInfinityWithoutTag();
    }

    public function readNull():Object {
        checkTag(HproseTags.TagNull);
        return null;
    }

    public function readEmpty():String {
        checkTag(HproseTags.TagEmpty);
        return '';
    }

    public function readBoolean():Boolean {
        var tag = stream.getc();
        switch (tag) {
            case HproseTags.TagTrue: return true;
            case HproseTags.TagFalse: return false;
            default: unexpectedTag(tag);
        }
    }

    public function readDateWithoutTag():Date {
        var year = parseInt(stream.read(4));
        var month = parseInt(stream.read(2)) - 1;
        var day = parseInt(stream.read(2));
        var date;
        var tag = stream.getc();
        if (tag == HproseTags.TagTime) {
            var hour = parseInt(stream.read(2));
            var minute = parseInt(stream.read(2));
            var second = parseInt(stream.read(2));
            var millisecond = 0;
            tag = stream.getc();
            if (tag == HproseTags.TagPoint) {
                millisecond = parseInt(stream.read(3));
                tag = stream.getc();
                if ((tag >= '0') && (tag <= '9')) {
                    stream.read(2);
                    tag = stream.getc();
                    if ((tag >= '0') && (tag <= '9')) {
                        stream.read(2);
                        tag = stream.getc();
                    }
                }
            }
            if (tag == HproseTags.TagUTC) {
                date = new Date(Date.UTC(year, month, day, hour, minute, second, millisecond));
            }
            else {
                date = new Date(year, month, day, hour, minute, second, millisecond);
            }
        }
        else if (tag == HproseTags.TagUTC) {
            date = new Date(Date.UTC(year, month, day));
        }
        else {
            date = new Date(year, month, day);
        }
		return date;
    }

    public function readDate():Date {
        var tag = stream.getc();
        switch (tag) {
            case HproseTags.TagDate: return readDateWithoutTag();
            case HproseTags.TagRef: return readRef();
            default: unexpectedTag(tag);
        }
    }

    public function readTimeWithoutTag():Date {
        var time;
        var hour = parseInt(stream.read(2));
        var minute = parseInt(stream.read(2));
        var second = parseInt(stream.read(2));
        var millisecond = 0;
        var tag = stream.getc();
        if (tag == HproseTags.TagPoint) {
            millisecond = parseInt(stream.read(3));
            tag = stream.getc();
            if ((tag >= '0') && (tag <= '9')) {
                stream.read(2);
                tag = stream.getc();
                if ((tag >= '0') && (tag <= '9')) {
                    stream.read(2);
                    tag = stream.getc();
                }
            }
        }
        if (tag == HproseTags.TagUTC) {
            time = new Date(Date.UTC(1970, 0, 1, hour, minute, second, millisecond));
        }
        else {
            time = new Date(1970, 0, 1, hour, minute, second, millisecond);
        }
		return time;
    }

    public function readTime():Date {
        var tag = stream.getc();
        switch (tag) {
            case HproseTags.TagTime: return readTimeWithoutTag();
            case HproseTags.TagRef: return readRef();
            default: unexpectedTag(tag);
        }
    }

    public function readUTF8CharWithoutTag():String {
        return stream.getc();
    }

    public function readUTF8Char():String {
        checkTag(HproseTags.TagUTF8Char);
        return stream.getc();
    }

    private function _readString():String {
        var str = stream.read(readInt(HproseTags.TagQuote));
        stream.skip(1);
        return str;
    }

    public function readStringWithoutTag():String {
        return _readString();
    }

    public function readString():String {
        var tag = stream.getc();
        switch (tag) {
            case HproseTags.TagString: return readStringWithoutTag();
            case HproseTags.TagRef: return readRef();
            default: unexpectedTag(tag);
        }
    }

    public function readGuidWithoutTag():String {
        stream.skip(1);
        var guid = stream.read(36);
        stream.skip(1);
        return guid;
    }

    public function readGuid():String {
        var tag = stream.getc();
        switch (tag) {
            case HproseTags.TagGuid: return readGuidWithoutTag();
            case HproseTags.TagRef: return readRef();
            default: unexpectedTag(tag);
        }
    }

    private function readListBegin():Array {
        return [];
    }

    private function readListEnd(list:Array):Array {
        var count = readInt(HproseTags.TagOpenbrace);
        for (var i = 0; i < count; i++) {
            list[i] = unserialize();
        }
        stream.skip(1);
        return list;
    }

    public function readListWithoutTag():Array {
        return readListEnd(readListBegin());
    }

    public function readList():Array {
        var tag = stream.getc();
        switch (tag) {
            case HproseTags.TagList: return readListWithoutTag();
            case HproseTags.TagRef: return readRef();
            default: unexpectedTag(tag);
        }
    }

    private function readMapBegin():Object {
        return {};
    }

    private function readMapEnd(map:Object):Object {
        var count = readInt(HproseTags.TagOpenbrace);
        for (var i = 0; i < count; i++) {
            var key = unserialize();
            map[key] = unserialize();
        }
        stream.skip(1);
        return map;
    }

    public function readMapWithoutTag():Object {
        return readMapEnd(readMapBegin());
    }

    public function readMap():Object {
        var tag = stream.getc();
        switch (tag) {
            case HproseTags.TagMap: return readMapWithoutTag();
            case HproseTags.TagRef: return readRef();
            default: unexpectedTag(tag);
        }
    }

    private function readObjectBegin():Object {
        var cls = classref[readInt(HproseTags.TagOpenbrace)];
        var obj = new cls.classname();
        return {obj: obj, cls: cls};
    }

    private function readObjectEnd(obj, cls):Object {
        for (var i = 0; i < cls.count; i++) {
            obj[cls.fields[i]] = unserialize();
        }
        stream.skip(1);
        return obj;
    }

    public function readObjectWithoutTag():Object {
        var result = readObjectBegin();
        return readObjectEnd(result.obj, result.cls);
    }

    public function readObject():Object {
        var tag = stream.getc();
        switch(tag) {
            case HproseTags.TagClass: readClass(); return readObject();
            case HproseTags.TagObject: return readObjectWithoutTag();
            case HproseTags.TagRef: return readRef();
            default: unexpectedTag(tag);
        }
    }

    private function readClass():Void {
        var classname = _readString();
        var count = readInt(HproseTags.TagOpenbrace);
        var fields = [];
        for (var i = 0; i < count; i++) {
            fields[i] = readString();
        }
        stream.skip(1);
        classref[classref.length] = {
            classname: HproseClassManager.getClass(classname),
            count: count,
            fields: fields
        };
    }

    private function readRef() {
        unexpectedTag(HproseTags.TagRef);
    }

    public function reset():Void {
        classref.length = 0;
    }
}