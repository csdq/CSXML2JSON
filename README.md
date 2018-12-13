# CSXML2JSON

### XML to JSON Objects



```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE note SYSTEM "Note.dtd">
<!-- Comments will be ignored -->
<cs:books groupId='123' xmlns:cs="http://xxxx.com">
    <book>
        <author id='1'>Tom</author>
        <title>The Apple</title>
        <publisher>O'Reilly</publisher>
    </book>
    <book>
        <author id='2'><id>13</id>Jack</author>
        <title>The sheep</title>
        <publisher><![CDATA[ O'Reilly ]]><![CDATA[ Publisher ]]></publisher>
    </book>
</cs:books>
```

```
{
"cs:books": {
    "xmlns:cs": "http://xxxx.com",
    "groupId": "123",
    "book": [
        {
            "author": {
                "id": "1",
                "#author_text": "Tom"
            },
            "publisher": "O'Reilly",
            "title": "The Apple"
            },
            {
            "author": {
                "id": [
                    "2",
                    "13"
                ],
                "#author_text": "Jack"
            },
            "publisher": "O'Reilly  Publisher",
            "title": "The sheep"
            }
        ]
    }
}
```
