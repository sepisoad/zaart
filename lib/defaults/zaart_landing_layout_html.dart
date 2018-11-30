const String ZAART_LANDING_LAYOUT_HTML = '''
<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="X-UA-Compatible" content="ie=edge">
  <meta author="{{author}}">
  <title>{{title}}</title>
  <link href="https://cdn.jsdelivr.net/npm/tailwindcss/dist/tailwind.min.css" rel="stylesheet">
  <link href="https://db.onlinewebfonts.com/c/4cc9d692753925335e7af83ecf6e6815?family=MuseoW01-900" rel="stylesheet">
  <link href="https://db.onlinewebfonts.com/c/75f171bc535016d4d2582e6f88d52796?family=Monaco" rel="stylesheet">
  <link href="theme/zaart.css" rel="stylesheet">
  <script src="theme/zaart.js"></script>
</head>

<body class="max-w-md mx-auto">
  <div class="flex justify-center mt-5">
    <div class="flex-row">
      <img class="rounded-full w-24" src="https://sepisoad.com/images/avatar.png" alt="">
    </div>
  </div>

  <div class="flex justify-center font-extrabold ">
    <h1 class="site-title">{{site.title}}</h1>
  </div>

  <div class="flex justify-center bg-grey-light rounded-full mb-5 mt-5">
    {{#site.pages}}
    <div class="flex-shrink text-grey-darker text-center  m-2 text-base">
      <a href="{{name}}.html">{{name}}</a>
    </div>
    {{/site.pages}}
  </div>

  <div class="flex">
    <PLACEHOLDER />
  </div>

  <div class="flex justify-between mb-5 mt-5 bg-grey-light p-2 rounded-full">
    <div class="">
      ©️ {{now.year}} Sepehr Aryani
    </div>
    <div class="">
      made with <a href=" https://github.com/sepisoad/zaart">zaart
      </a> </div>
  </div>
</body>

</html>
''';
