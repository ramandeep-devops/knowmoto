//
//  DataParser.swift
//  AE
//
//  Created by MAC_MINI_6 on 16/04/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import Foundation
import Moya

extension TargetType {
  
  func parseModel(data: Data) -> Any? {
    switch self {
  
    case is EP_Login: //Login
      let endpoint = self as! EP_Login
      
      switch endpoint {
        
      case.loginAndNumberVerification(_),.getOtp(_),.signUp(_),.signIn(_):
        
        let model = JSONHelper<RootModel<UserData>>().getCodableModel(data: data)?.data
        
        return model

      case .getImageSignedUrl(_):
        
        return JSONHelper<RootModel<ImageUrlModel>>().getCodableModel(data: data)?.data

        
      default:
        return nil
      }
        
    case is EP_Profile: //profile
        
        let endpoint = self as! EP_Profile
        switch endpoint {
            
        case .get_make_model_list(_),.get_model_listing(_):
            
            return JSONHelper<RootModel<CarBrandsModel>>().getCodableModel(data: data)?.data

            
        case .updateProfile(_),.user_profile(_):
            
            return JSONHelper<RootModel<UserData>>().getCodableModel(data: data)?.data
            
        case .get_beacons(_):
            
            return JSONHelper<RootModel<BeaconsModel>>().getCodableModel(data: data)?.data
            
        case .add_beacons(_):
            
            return JSONHelper<RootModel<BeaconlistModel>>().getCodableModel(data: data)?.data
            
            
        case .get_user_associated_cars(_):
            
            return JSONHelper<RootModel<AssociatedOrBookMarkCarsModel>>().getCodableModel(data: data)?.data
            
        default:
            return nil
        }
        
    case is EP_Car: //car
        
        let endpoint = self as! EP_Car
        switch endpoint {
            
        case .get_features(_),.get_sponsor_list(_),.get_modification_category(_),.get_available_fm(_):
            
            return JSONHelper<RootDataListModel<FeaturesListModel>>().getCodableModel(data: data)?.data?.list
            
        case .get_make_years(_):
            
            return JSONHelper<RootModel<YearPickerModel>>().getCodableModel(data: data)?.data
            
        case .get_car_feeds(_),.get_beacon_vehicles(_):
        
            return JSONHelper<RootDataListModel<CarListDataModel>>().getCodableModel(data: data)?.data?.list
            
        case .colorsList():
            
            return JSONHelper<RootDataListModel<BrandOrCarModel>>().getCodableModel(data: data)?.data?.list
            
            
        default:
            return nil
        }
        
    case is EP_Home: //home
        
        let endpoint = self as! EP_Home
        switch endpoint {
            
        case .get_home_feed(_):
            return JSONHelper<RootModel<HomeDataList>>().getCodableModel(data: data)?.data
//            
//        case .news(_):
//            return JSONHelper<News>().getCodableModel(data: data)
            
        case .search(_):
            return JSONHelper<RootDataListModel<SearchDataModel>>().getCodableModel(data: data)?.data?.list
            
        case .get_most_trending(_):
            return JSONHelper<RootModel<TrendingData>>().getCodableModel(data: data)?.data
            
            
        default:
            return data
        }
        
    case is EP_Post: //Post
        
        let endpoint = self as! EP_Post
        switch endpoint {
            
            
        case .get_post_data(_):
            return JSONHelper<RootDataListModel<PostList>>().getCodableModel(data: data)?.data?.list
            
        case .get_main_search_data(let _,let _,let type,let _,let _,let _):
            
            if type == 1{
                return JSONHelper<RootDataListModel<CarListDataModel>>().getCodableModel(data: data)?.data
            }else{
                return JSONHelper<RootDataListModel<PostList>>().getCodableModel(data: data)?.data
            }
            
        default:
            return nil
        }
        
    case is EP_Notification: //Notification
        
        let endpoint = self as! EP_Notification
        
        switch endpoint {
            
        case .get_unread_notification_count():
            
            return JSONHelper<RootModel<NotificationData>>().getCodableModel(data: data)?.data
            
        case .get_notifications(_):
            return JSONHelper<RootDataListModel<NotificationData>>().getCodableModel(data: data)?.data?.list
            
        default:
            return nil
        }

    default:
      return nil
    }
    
    
  }
}
