class radioItem {
    String kategori;
    String lang;
    String stream_path;
    String title;

    radioItem({this.kategori, this.lang, this.stream_path, this.title});

    factory radioItem.fromJson(Map<String, dynamic> json) {
        return radioItem(
            kategori: json['kategori'], 
            lang: json['lang'], 
            stream_path: json['stream_path'], 
            title: json['title'], 
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['kategori'] = this.kategori;
        data['lang'] = this.lang;
        data['stream_path'] = this.stream_path;
        data['title'] = this.title;
        return data;
    }
}