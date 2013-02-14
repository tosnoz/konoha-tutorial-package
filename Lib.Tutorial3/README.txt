Tutorial3 クラスを定義する

このパッケージではクラスの作成方法について説明していきます。

目次
1. スクリプトで定義するクラス、C言語で定義するクラス
2. クラスの定義
3. Konoha言語への登録
4. 注意事項

1. スクリプトで定義するクラス、C言語で定義するクラス
2. クラスの定義
3. Konoha言語への登録


あとで書く
Tutorial3_Init() でそのオブジェクトの NULL オブジェクトが用意される
malloc(2) 系は使うべきではない
-----
Memory obtained by malloc function allocates a memory region that is not managed by GC.
Therefore, sometimes malloc function leads to unexpected fragmentation.
So, you may want to create konoha-object without malloc.
-----

4. 注意事項
C言語で定義されたクラスはFinalなクラスとして定義されます。
C言語で定義されたクラスをスクリプト側でextendしたい場合には以下のようにラップするオブジェクトを作成することで回避する方法をとっています。

/* defined by C exntension */
class CDefinedClass;

class MyClass /* exnteds CDefinedClass */ {
    CDefinedClass superObject;
    MyClass() {
        superObject = new CDefinedClass();
        ...
    }
}

