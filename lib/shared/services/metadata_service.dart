import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'dart:convert';

class MetadataService {
  static Future<Map<String, String?>> fetchMetadata(String url) async {
    try {
      final uri = Uri.parse(url);
      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final document = parse(response.body);
        
        String? getMeta(String property) {
          return document
              .querySelector('meta[property="$property"]')
              ?.attributes['content'] ??
              document
              .querySelector('meta[name="$property"]')
              ?.attributes['content'];
        }

        final title = getMeta('og:title') ?? 
                     getMeta('twitter:title') ?? 
                     document.querySelector('title')?.text;
        
        final description = getMeta('og:description') ?? 
                           getMeta('twitter:description') ?? 
                           getMeta('description');
        
        // 1. Try common meta tags
        String? image = getMeta('og:image') ?? 
                        getMeta('twitter:image') ?? 
                        getMeta('image');

        // 2. Try JSON-LD (Search for Schema.org image)
        if (image == null) {
          try {
            final scripts = document.querySelectorAll('script[type="application/ld+json"]');
            for (var script in scripts) {
              final json = jsonDecode(script.text);
              if (json is Map) {
                image = _findImageInJson(json);
                if (image != null) break;
              } else if (json is List) {
                for (var item in json) {
                  if (item is Map) {
                    image = _findImageInJson(item);
                    if (image != null) break;
                  }
                }
                if (image != null) break;
              }
            }
          } catch (_) {}
        }

        // 3. Try high-quality link tags
        image ??= document.querySelector('link[rel="image_src"]')?.attributes['href'] ??
                 document.querySelector('link[rel="apple-touch-icon"]')?.attributes['href'] ??
                 document.querySelector('link[rel="shortcut icon"]')?.attributes['href'];

        // 4. Try specific professional profile classes
        image ??= document.querySelector('.profile-image img')?.attributes['src'] ??
                   document.querySelector('.avatar img')?.attributes['src'] ??
                   document.querySelector('img[src*="profile"]')?.attributes['src'] ??
                   document.querySelector('img[src*="avatar"]')?.attributes['src'];

        // Normalize relative URLs
        if (image != null && !image.startsWith('http')) {
          if (image.startsWith('//')) {
            image = '${uri.scheme}:$image';
          } else if (image.startsWith('/')) {
            image = '${uri.scheme}://${uri.host}$image';
          } else {
            // Check if it's a relative path to the current URL
            String path = uri.path;
            if (path.isEmpty) path = '/';
            if (!path.endsWith('/')) {
              path = path.substring(0, path.lastIndexOf('/') + 1);
            }
            image = '${uri.scheme}://${uri.host}$path$image';
          }
        }
        
        return {
          'title': title?.trim(),
          'description': description?.trim(),
          'image': image,
          'domain': uri.host,
        };
      }
    } catch (e) {
      // Log error
    }
    return {
      'domain': Uri.parse(url).host,
    };
  }

  static String? _findImageInJson(Map json) {
    if (json.containsKey('image')) {
      final img = json['image'];
      if (img is String) return img;
      if (img is Map && img.containsKey('url')) return img['url'].toString();
      if (img is List && img.isNotEmpty) {
        if (img[0] is String) return img[0];
        if (img[0] is Map && img[0].containsKey('url')) return img[0]['url'].toString();
      }
    }
    if (json.containsKey('logo')) {
      final logo = json['logo'];
      if (logo is String) return logo;
      if (logo is Map && logo.containsKey('url')) return logo['url'].toString();
    }
    return null;
  }
}
