part of angular.core.dom_internal;

/**
 * Global configuration options for the Compiler
 */
@Injectable()
class CompilerConfig {
  /**
   * True if the compiler should add ElementProbes to the elements.
   */
  final bool elementProbeEnabled;

  CompilerConfig() : elementProbeEnabled = true;
  CompilerConfig.withOptions({this.elementProbeEnabled: true});
}
