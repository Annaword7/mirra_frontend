import 'package:flutter_test/flutter_test.dart';
import 'package:mi_r_r_a_dev/design_system/foundations/image_thumb.dart';

void main() {
  const storageUrl =
      'https://project.supabase.co/storage/v1/object/public/images/users_images/1.png';

  test('ссылка на Storage переписывается в уменьшенную версию', () {
    expect(
      thumbUrl(storageUrl, width: 400),
      'https://project.supabase.co/storage/v1/render/image/public/images/users_images/1.png'
      '?width=400&quality=75',
    );
  });

  test('качество настраивается', () {
    expect(thumbUrl(storageUrl, width: 200, quality: 60),
        endsWith('?width=200&quality=60'));
  });

  test('существующая query-строка сохраняется', () {
    expect(
      thumbUrl('$storageUrl?token=abc', width: 200),
      endsWith('1.png?token=abc&width=200&quality=75'),
    );
  });

  test('чужие ссылки остаются нетронутыми', () {
    const external = 'https://cdn.example.com/product/1.jpg';
    expect(thumbUrl(external, width: 400), external);
  });
}
