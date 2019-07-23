import Flutter
import UIKit
import Mixpanel
    
public class SwiftFluttermixpanelPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "g123k/fluttermixpanel", binaryMessenger: registrar.messenger())
    let instance = SwiftFluttermixpanelPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as! NSDictionary
    let token = (args["token"] as! String)
    
    if (token.isEmpty) {
        result(FlutterError.init(code: "NOT_INITIALIZED", message: "Please initialize the Mixpanel API first with a valid token", details: nil))
        return
    }
    
    let mixpanel = Mixpanel.initialize(token: token)

    switch (call.method) {
    case "people/set":
        setPeople(args: args, result: result, mixpanel: mixpanel)
    case "people/setMap":
        setPeopleMap(args: args, result: result, mixpanel: mixpanel)
    case "people/identify":
        setPeopleIdentify(args: args, result: result, mixpanel: mixpanel)
    case "identify":
        setIdentify(args: args, result: result, mixpanel: mixpanel)
    case "track":
        track(args: args, result: result, mixpanel: mixpanel)
    case "track_map":
        trackMap(args: args, result: result, mixpanel: mixpanel)
    case "track_json":
        trackJson(args: args, result: result, mixpanel: mixpanel)
    case "get_distinct_id":
        getDistinctId(result: result, mixpanel: mixpanel)
    case "flush":
        flush(result: result, mixpanel: mixpanel)
    default:
        result(FlutterMethodNotImplemented)
    }
    
    
    mixpanel.flush()
  }


    func setPeople(args: NSDictionary, result: @escaping FlutterResult, mixpanel : MixpanelInstance) {
        let propertyName = (args["property_name"] as! String)
        let value = (args["value"] as! String)

        if (propertyName.isEmpty) {
            result(FlutterError.init(code: "ERROR", message: "The propertyName argument is missing!", details: nil))
            return
        }

        mixpanel.people.set(property: propertyName, to: value)
        result(nil)
    }

    func setPeopleMap(args: NSDictionary, result: @escaping FlutterResult, mixpanel : MixpanelInstance) {
        let propertiesMap = (args["properties_map"] as? NSDictionary)

        if (propertiesMap == nil) {
            result(FlutterError.init(code: "ERROR", message: "The properties map argument is missing!", details: nil))
            return
        }

        let props = propertiesMap as! Dictionary<String, Any>
        var map = [String: MixpanelType]()

        for (key, value) in props {
            map[key] = value as? MixpanelType;
        }

        mixpanel.people.set(properties: map)
        result(nil)
    }

    func setPeopleIdentify(args: NSDictionary, result: @escaping FlutterResult, mixpanel : MixpanelInstance) {
        setIdentify(args: args, result: result, mixpanel: mixpanel)
    }

    func setIdentify(args: NSDictionary, result: @escaping FlutterResult, mixpanel : MixpanelInstance) {
        let id = (args["distinct_id"] as! String)

        if (id.isEmpty) {
            result(FlutterError.init(code: "ERROR", message: "The distinct_id argument is missing!", details: nil))
            return
        }

        mixpanel.identify(distinctId: id)
        result(nil)
    }


    func track(args: NSDictionary, result: @escaping FlutterResult, mixpanel : MixpanelInstance) {
        let eventName = (args["event_name"] as! String)
        
        if (eventName.isEmpty) {
            result(FlutterError.init(code: "ERROR", message: "The event name argument is missing!", details: nil))
            return
        }
        
        mixpanel.track(event: eventName)
        result(nil)
    }
    
    func trackMap(args: NSDictionary, result: @escaping FlutterResult, mixpanel : MixpanelInstance) {
        
        let eventName = (args["event_name"] as! String)
        let propertiesMap = (args["properties_map"] as? NSDictionary)
        
        if (eventName.isEmpty) {
            result(FlutterError.init(code: "ERROR", message: "The event name argument is missing!", details: nil))
            return
        } else if (propertiesMap == nil) {
            result(FlutterError.init(code: "ERROR", message: "The properties map argument is missing!", details: nil))
            return
        }
        
        let props = propertiesMap as! Dictionary<String, Any>
        var map = [String: MixpanelType]()
        
        for (key, value) in props {
            map[key] = value as? MixpanelType;
        }
        
        mixpanel.track(event: eventName, properties: map)
        result(nil)
    }
    
    func trackJson(args: NSDictionary, result: @escaping FlutterResult, mixpanel : MixpanelInstance) {
        print(args)
        
        let eventName = (args["event_name"] as! String)
        let propertiesJson = (args["properties_json"] as? String)
        
        if (eventName.isEmpty) {
            result(FlutterError.init(code: "ERROR", message: "The event name argument is missing!", details: nil))
            return
        } else if (propertiesJson == nil) {
            result(FlutterError.init(code: "ERROR", message: "The properties map argument is missing!", details: nil))
            return
        }
        
        let props = convertToDictionary(text: propertiesJson as! String)
        print(props)
        
        mixpanel.track(event: eventName, properties: props as! Dictionary<String, String>)
        result(nil)
    }
    
    func getDistinctId(result: @escaping FlutterResult, mixpanel : MixpanelInstance) {
        result(mixpanel.distinctId)
    }
    
    func flush(result: @escaping FlutterResult, mixpanel : MixpanelInstance) {
        mixpanel.flush()
        result(nil)
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}
