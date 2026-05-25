# HTTP Echo Server

Gibt alle eingehenden HTTP-Requests als JSON-Antwort zurück. Keine externen Abhängigkeiten – nur Python 3.

## Starten

```bash
python server.py
```

Mit optionalen Parametern:

```bash
python server.py --host 127.0.0.1 --port 9000
```

## Testen

```bash
# GET
curl http://localhost:8080/hello

# POST mit Body
curl -X POST http://localhost:8080/api/data \
  -H "Content-Type: application/json" \
  -d '{"key": "value"}'
```

### Beispiel-Antwort

```json
{
  "method": "POST",
  "path": "/api/data",
  "headers": {
    "Host": "localhost:8080",
    "Content-Type": "application/json",
    "Content-Length": "15"
  },
  "body": "{\"key\": \"value\"}"
}
```

## Anpassen

Die Klasse `EchoHandler` in `server.py` enthält die gesamte Logik. Typische Anpassungen:

- **Andere HTTP-Methode abfangen**: Eigene Methode `do_PUT(self)` implementieren statt `do_request` zu verwenden
- **Antwort-Format ändern**: `response`-Dict in `do_request` anpassen
- **Eigene Header hinzufügen**: `self.send_header(...)` vor `self.end_headers()` einfügen
