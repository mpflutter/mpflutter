part of dart.ui;

class MockScene implements Scene {
  Future<Image> toImage(int width, int height) async {
    throw "";
  }

  void dispose() {}
}

class MockSceneBuilder implements SceneBuilder {
  OffsetEngineLayer? pushOffset(
    double dx,
    double dy, {
    OffsetEngineLayer? oldLayer,
  }) {
    return null;
  }

  TransformEngineLayer? pushTransform(
    Float64List matrix4, {
    TransformEngineLayer? oldLayer,
  }) {
    return null;
  }

  ClipRectEngineLayer? pushClipRect(
    Rect rect, {
    Clip clipBehavior = Clip.antiAlias,
    ClipRectEngineLayer? oldLayer,
  }) {
    return null;
  }

  ClipRRectEngineLayer? pushClipRRect(
    RRect rrect, {
    required Clip clipBehavior,
    ClipRRectEngineLayer? oldLayer,
  }) {
    return null;
  }

  ClipPathEngineLayer? pushClipPath(
    Path path, {
    Clip clipBehavior = Clip.antiAlias,
    ClipPathEngineLayer? oldLayer,
  }) {
    return null;
  }

  OpacityEngineLayer? pushOpacity(
    int alpha, {
    Offset offset = Offset.zero,
    OpacityEngineLayer? oldLayer,
  }) {
    return null;
  }

  ColorFilterEngineLayer? pushColorFilter(
    ColorFilter filter, {
    ColorFilterEngineLayer? oldLayer,
  }) {
    return null;
  }

  ImageFilterEngineLayer? pushImageFilter(
    ImageFilter filter, {
    ImageFilterEngineLayer? oldLayer,
  }) {
    return null;
  }

  BackdropFilterEngineLayer? pushBackdropFilter(
    ImageFilter filter, {
    BackdropFilterEngineLayer? oldLayer,
  }) {
    return null;
  }

  ShaderMaskEngineLayer? pushShaderMask(
    Shader shader,
    Rect maskRect,
    BlendMode blendMode, {
    ShaderMaskEngineLayer? oldLayer,
  }) {
    return null;
  }

  PhysicalShapeEngineLayer? pushPhysicalShape({
    required Path path,
    required double elevation,
    required Color color,
    Color? shadowColor,
    Clip clipBehavior = Clip.none,
    PhysicalShapeEngineLayer? oldLayer,
  }) {
    return null;
  }

  void addRetained(EngineLayer retainedLayer) {}
  void pop() {}
  void addPerformanceOverlay(int enabledOptions, Rect bounds) {}
  void addPicture(
    Offset offset,
    Picture picture, {
    bool isComplexHint = false,
    bool willChangeHint = false,
  }) {}
  void addTexture(
    int textureId, {
    Offset offset = Offset.zero,
    double width = 0.0,
    double height = 0.0,
    bool freeze = false,
    FilterQuality filterQuality = FilterQuality.low,
  }) {}
  void addPlatformView(
    int viewId, {
    Offset offset = Offset.zero,
    double width = 0.0,
    double height = 0.0,
  }) {}
  void addChildScene({
    Offset offset = Offset.zero,
    double width = 0.0,
    double height = 0.0,
    required SceneHost sceneHost,
    bool hitTestable = true,
  }) {}
  void setRasterizerTracingThreshold(int frameInterval) {}
  void setCheckerboardRasterCacheImages(bool checkerboard) {}
  void setCheckerboardOffscreenLayers(bool checkerboard) {}
  Scene build() {
    return MockScene();
  }

  void setProperties(
    double width,
    double height,
    double insetTop,
    double insetRight,
    double insetBottom,
    double insetLeft,
    bool focusable,
  ) {}
}
