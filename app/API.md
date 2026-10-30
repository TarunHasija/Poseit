# Poseit Backend API

This guide documents the FastAPI endpoints and shows how to call them from the Flutter client.

## Base URL

Use the API server's origin without a trailing slash:

| Where the Flutter app runs | Base URL example |
| --- | --- |
| Android emulator, local API | `http://10.0.2.2:8000` |
| iOS simulator, local API | `http://127.0.0.1:8000` |
| Physical device, local API | `http://<computer-LAN-IP>:8000` |
| Deployed API | `https://<your-render-service>.onrender.com` |

`localhost` on a phone or emulator points to that device, not your development computer. Start the backend locally with Uvicorn, or deploy it before using the Render URL.

## Authentication

Signup and login are public endpoints. The pose endpoints require a Supabase access token in the standard bearer header:

```http
Authorization: Bearer <access_token>
```

### `POST /auth/signup`

Creates a Supabase email/password user. JSON body:

```json
{
  "email": "person@example.com",
  "password": "at-least-8-characters"
}
```

Password must be at least 8 characters. The response contains `message` and `user`. Depending on the Supabase email-confirmation setting, the user may need to verify their email before logging in. Signup does not return an access token in this API.

### `POST /auth/login`

JSON body is the same as signup. A successful response contains:

```json
{
  "message": "Login successful",
  "access_token": "...",
  "refresh_token": "...",
  "expires_at": 1234567890,
  "user": {
    "id": "user-uuid",
    "email": "person@example.com",
    "email_confirmed_at": null,
    "phone_confirmed_at": null
  }
}
```

Send `access_token` as a bearer token for pose calls. Do not put the Supabase service-role key in the Flutter app; it belongs only in the backend's environment.

## Pose endpoints

All pose endpoints require `Authorization: Bearer <access_token>`.

### `POST /poses`

Uploads one image as `multipart/form-data`. The form field name must be `file`.

Supported content types are `image/jpeg`, `image/png`, `image/webp`, and `image/gif`; the file contents are decoded and checked against the declared MIME type. Uploads are limited to 15 MiB. Images are optimized before being stored in the configured private Supabase bucket (`poses` by default).

Success status: `201 Created`. The response is pose metadata:

```json
{
  "id": "pose-uuid",
  "bucket_name": "poses",
  "object_path": "pose-uuid.jpg",
  "original_filename": "pose.jpg",
  "mime_type": "image/jpeg",
  "size_bytes": 123456,
  "original_size_bytes": 234567,
  "width": 800,
  "height": 1200,
  "created_at": "2026-10-18T12:00:00Z"
}
```

### `POST /poses/bulk`

Uploads multiple images in one `multipart/form-data` request. Repeat the
`files` field once for each image. Each returned `id` is a unique image ID.
To apply the same metadata, including multiple categories, to every image, send
one `metadata` text field containing a JSON object. Use `poses` for different
metadata per image; its JSON array aligns by order with the repeated `files` rows.

| Field | Type | Meaning |
| --- | --- | --- |
| `files` | file, repeated | JPEG, PNG, WEBP, or GIF image; up to 20 images |
| `metadata` | JSON text | One metadata object shared by all files: `categories`, `people_count`, and `created_at` |
| `poses` | JSON text | Per-image array with `categories`, `people_count`, and `created_at` |
| `people_count`, `category`, `created_at` | form fields | Legacy shared mode with a single category. Use instead of `metadata` or `poses`. |

Each image is limited to 15 MiB and the combined original upload size is
limited to 100 MiB. The server validates and optimizes each image, stores all
objects in the private bucket, and returns a list of pose metadata with status
`201 Created`. If an image or database write fails, the request is rolled back
and uploaded storage objects are removed where possible.

Example:

```bash
METADATA='{"categories":["standing","yoga"],"people_count":2,"created_at":"2026-10-25T10:30:00Z"}'
curl -X POST "$API_BASE_URL/poses/bulk" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -F "files=@./front.jpg" \
  -F "files=@./side.png" \
  -F "metadata=$METADATA"
```

For different metadata per file:

```bash
POSES='[{"categories":["standing","yoga"],"people_count":2,"created_at":"2026-10-25T10:30:00Z"},{"categories":["stretching","solo"],"people_count":1,"created_at":"2026-10-25T10:35:00Z"}]'
curl -X POST "$API_BASE_URL/poses/bulk" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -F "files=@./front.jpg" \
  -F "files=@./side.png" \
  -F "poses=$POSES"
```

The response is an array. Each item includes its own unique `id` plus its
metadata, image dimensions, categories, and storage details. The `poses` array
length must match the number of files. `metadata`, `poses`, and legacy fields
are mutually exclusive. Apply Alembic migrations through `0005_remove_gender_counts`
before using this code.

### `GET /poses`

Returns the full pose catalog, including each image as base64. Each item contains all the metadata above plus `image_base64`:

```json
[
  {
    "id": "pose-uuid",
    "bucket_name": "poses",
    "object_path": "pose-uuid.jpg",
    "original_filename": "pose.jpg",
    "mime_type": "image/jpeg",
    "size_bytes": 123456,
    "original_size_bytes": 234567,
    "width": 800,
    "height": 1200,
    "created_at": "2026-10-18T12:00:00Z",
    "image_base64": "/9j/4AAQSk..."
  }
]
```

This endpoint downloads all objects and returns them in one response, so response size and memory use grow with the catalog. Use it when the whole catalog is needed at once.

### `GET /poses/{pose_id}`

Returns the image bytes directly with its image MIME type (for example, `image/jpeg`). The response includes metadata in headers such as `X-Pose-Id`, `X-Pose-Width`, `X-Pose-Height`, `X-Pose-Size`, and `X-Pose-Created-At`. A missing UUID returns `404`.

### `PATCH /poses/{pose_id}`

Edits pose metadata without uploading or replacing its image. Send any subset of
`people_count`, `category` or `categories`, and `created_at` as JSON. Counts
must be zero or greater; category must contain 1–120 non-whitespace characters.
The endpoint returns the updated pose metadata. A missing pose returns `404`.

Example request body:

```json
{
  "categories": ["standing", "yoga"],
  "people_count": 2
}
```

Omitted fields remain unchanged. Supplying `categories` replaces the pose's
category set; an empty list clears it. Each category name is trimmed and stored
in lowercase. Supplying the legacy singular `category` replaces the set with
that one category. The category table stores each name once, and the composite
primary key on `(pose_id, category_id)` prevents duplicate links. Apply the
Alembic migrations through `0005_remove_gender_counts` before deploying this API change.

## Common errors

| Status | Meaning |
| --- | --- |
| `400` | Signup or login failed; inspect the response `detail`. |
| `401` | Missing, expired, or invalid bearer token. Log in again and retry. |
| `404` | No pose exists for the requested ID. |
| `413` | Upload is larger than 15 MiB. |
| `415` | MIME type is not supported, or file bytes do not match the declared image type. |
| `422` | Request body, UUID, or required file field is invalid. |
| `502` | Supabase Storage operation failed. Check backend logs and Supabase configuration. |

## Flutter setup

Add direct dependencies for HTTP requests and MIME detection:

```shell
flutter pub add http http_parser mime
```

Set the API base URL when running the app. For example, on an Android emulator:

```shell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

For production, set `API_BASE_URL` to the Render service URL. Do not include `/docs` or an endpoint path in the base URL.

## Flutter API client example

Create a small API client (for example, `lib/core/network/pose_api.dart`):

```dart
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

const apiBaseUrl = String.fromEnvironment('API_BASE_URL');

class PoseApi {
  PoseApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  String? _accessToken;

  Map<String, String> get _authHeaders => {
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
      };

  Uri _uri(String path) => Uri.parse('$apiBaseUrl$path');

  Future<void> login(String email, String password) async {
    final response = await _client.post(
      _uri('/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode != 200) {
      throw Exception('Login failed (${response.statusCode}): ${response.body}');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    _accessToken = json['access_token'] as String;
  }

  Future<Map<String, dynamic>> uploadPose(String filePath) async {
    final mime = lookupMimeType(filePath) ?? 'application/octet-stream';
    final request = http.MultipartRequest('POST', _uri('/poses'))
      ..headers.addAll(_authHeaders)
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        filePath,
        contentType: MediaType.parse(mime),
      ));

    final streamed = await _client.send(request);
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode != 201) {
      throw Exception('Upload failed (${response.statusCode}): ${response.body}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getAllPoses() async {
    final response = await _client.get(_uri('/poses'), headers: _authHeaders);
    if (response.statusCode != 200) {
      throw Exception('Fetch failed (${response.statusCode}): ${response.body}');
    }
    return (jsonDecode(response.body) as List<dynamic>)
        .cast<Map<String, dynamic>>();
  }

  Future<List<int>> getPoseBytes(String poseId) async {
    final response = await _client.get(
      _uri('/poses/$poseId'),
      headers: _authHeaders,
    );
    if (response.statusCode != 200) {
      throw Exception('Fetch failed (${response.statusCode}): ${response.body}');
    }
    return response.bodyBytes;
  }

  void dispose() => _client.close();
}
```

Use the returned bytes from `getPoseBytes` directly in Flutter, for example `Image.memory(bytes)`. To render an item from `getAllPoses`, decode its base64 field:

```dart
final bytes = base64Decode(pose['image_base64'] as String);
Image.memory(bytes);
```

For an authenticated upload, call `login` first, then pass a local image path to `uploadPose`. If the app needs to keep a session after it closes, store tokens with an OS-backed secure-storage solution rather than plain preferences. Never store the service-role key in the client.

## Inspecting the API

With the backend running, Swagger UI is available at `/docs` on the API base URL. It can be used to inspect schemas and manually try calls. Log in first, copy `access_token`, click **Authorize**, enter `Bearer <access_token>`, then try the pose routes.

## Database migrations (Alembic)

Alembic is configured at the repository root. The API no longer creates tables on startup, so apply migrations before starting against a new database.

After changing a SQLAlchemy model, generate a revision from the repository root:

```shell
alembic revision --autogenerate -m "describe the schema change"
```

Review the generated Python file in `migrations/versions/`; autogeneration is a draft and should be checked before applying. Apply pending revisions with:

```shell
alembic upgrade head
```

For an existing database that already has the original `pose_images` table from the older SQL migration, baseline it before using Alembic. If it has only the original columns, run `alembic stamp 0001_pose_schema` and then `alembic upgrade head`. If the bulk metadata columns were already added by `20261025_add_bulk_pose_metadata.sql`, run `alembic stamp head` instead. `stamp` records the current revision without changing tables, so confirm the actual schema matches first.

The older `.sql` files in `migrations/` are retained as historical records. Use Alembic revisions for future changes instead of manually rerunning those files.
