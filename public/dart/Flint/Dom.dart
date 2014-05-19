part of Flint;

abstract class Dom{
  Element domElement;

  /** =========== HTML MANIPULATION =============*/
  // returns HTML for the element
  String html(){
    return domElement.innerHTML;
  }

  //sets html for the element;
  void setHtml(String newHTML){
    domElement.innerHtml = newHTML;
  }

  /** =========== CSS MANIPULATION =============*/
  void setStyles(List<String> newStyles){
    for(var i in newStyles){
      domElement.style[i] = newStyles[i];
    }
  }


}