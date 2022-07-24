# vim-rst-util

## Key maps to add sections

* `<Plug>(rst-section1)` : Add an underline ( = ) of the same length as the current line.
* `<Plug>(rst-section2)` : Add an underline ( - ) of the same length as the current line.
* `<Plug>(rst-section3)` : Add an underline ( ~ ) of the same length as the current line.
* `<Plug>(rst-section4)` : Add an underline ( " ) of the same length as the current line.
* `<Plug>(rst-section5)` : Add an underline ( ' ) of the same length as the current line.
* `<Plug>(rst-section6)` : Add an underline ( ` ) of the same length as the current line.

## Key maps to insert list item

`_` is cursor position.

* `<Plug>(rst-insert-samebullet)`

  ```
  hoge_ -> * hoge_

  * hoge_ -> * hoge
             * _

  1. hoge_ -> 1. hoge
              2. _

  * | hoge  -> * | hoge
    | fuga_      | fuga
               * _

  #. | hoge   -> #. | hoge
     | fuga_        | fuga
                 #. _
  ```

* `<Plug>(rst-insert-childbullet)`

  ```
  * hoge_ -> * hoge

              + _

  * | hoge  -> * | hoge
    | fuga_      | fuga

                 + _

  #. | hoge  -> #. | hoge
     | fuga_       | fuga

                  a. _

  ```

* `<Plug>(rst-insert-parentbullet)`

  ```
  + hoge_ ->   + hoge

             * _

  a. | hoge  ->   a. | hoge
     | fuga_         | fuga

                #. _

  ```

## Key maps to insert line block

* `<Plug>(rst-insert-lineblock)`

  ```
  * | hoge_ -> * | hoge
                 | _

  | hoge_ -> | hoge
             | _

  #. hoge_ -> #. | hoge
                 | _

  * hoge_ -> * | hoge
               | _

  hoge- -> | hoge
           | _
  ```