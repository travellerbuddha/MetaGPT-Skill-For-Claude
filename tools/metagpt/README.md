# MetaGPT + Claude

[MetaGPT](https://github.com/FoundationAgents/MetaGPT) çok ajanlı bir framework; buradaki kurulum onu LLM olarak Claude ile çalıştırır.

## Kurulum

Cloud oturumlarında `.claude/hooks/session-start.sh` bunu otomatik yapar. Elle:

```bash
export ANTHROPIC_API_KEY=...        # cloud'da: ortam ayarları → Environment variables
./tools/metagpt/setup.sh            # vendor/MetaGPT + Python 3.11 venv + ~/.metagpt/config2.yaml
```

Model varsayılanı `claude-opus-5-5`; değiştirmek için `METAGPT_CLAUDE_MODEL=claude-sonnet-5-5 ./tools/metagpt/setup.sh`.

## Kullanım

```bash
vendor/MetaGPT/.venv/bin/metagpt "Bir otel rezervasyon formu için basit bir web uygulaması yaz" --investment 3
```

`--investment` dolar cinsinden bütçedir; Claude fiyatları tabloya eklendiği için gerçekten uygulanır.

## Upstream'e göre farklar

MetaGPT `11cdf466` sürümüne sabitlenir ve `patches/0001-claude-5x-support.patch` uygulanır:

- **Thinking:** Claude 4.6+ / 5.x modellerine `budget_tokens` gönderilmez (HTTP 400 verirdi). `reasoning: true` adaptive thinking özetlerini açar, `reasoning_effort` ise `output_config.effort` olarak gönderilir.
- **Yanıt ayrıştırma:** Birden fazla text bloğu ve boş thinking blokları doğru birleştirilir. `refusal` / `max_tokens` durma nedenleri loglanır.
- **Maliyet:** Akışlı (streaming) çağrılarda maliyet artık kaydedilir. Opus/Sonnet/Haiku/Fable 5.x fiyatları ve 1M bağlam pencereleri tablolara eklendi.
- **Token sayma:** `ANTHROPIC_API_KEY` ortam değişkeni yoksa çökmez, yaklaşık tahmine düşer.
- **Görseller:** OpenAI formatı yerine Anthropic `image` blokları gönderilir.
- **base_url:** Varsayılan OpenAI adresi kalırsa Anthropic adresine düşer.

`overrides.txt`, PyPI'dan silinmiş `lancedb==0.4.0`'ı ve `typer 0.9`'u kıran `click>=8.2`'yi düzeltir.

## Bilinen sınırlar

- RAG / uzun süreli bellek gibi embedding gerektiren özellikler için Claude'un embedding modeli yok; bu özellikler ayrı bir embedding sağlayıcısı (`embedding:` bölümü) ister.
- Upstream'in `tests/metagpt/provider/test_anthropic_api.py` testi yamasız kodda da kırık (eski SDK tipleri); yamayla ilgili değil.
