#pragma once

#include <string>
#include <networktables/StringPublisher.h>
#include <networktables/StringTopic.h>
#include <wpi/json.h>

class Elastic {
 public:
  struct ElasticNotification {
    enum class NotificationLevel {
      INFO,
      WARNING,
      ERROR
    };

    ElasticNotification(NotificationLevel level, const std::string& title, const std::string& description);

    void SetLevel(NotificationLevel level);
    NotificationLevel GetLevel() const;

    void SetTitle(const std::string& title);
    std::string GetTitle() const;

    void SetDescription(const std::string& description);
    std::string GetDescription() const;

    std::string ToJson() const;

    static std::string NotificationLevelToString(NotificationLevel level);

   private:
    NotificationLevel level;
    std::string title;
    std::string description;
  };

  static void SendAlert(const ElasticNotification& alert);

 private:
  static nt::StringTopic topic;
  static nt::StringPublisher publisher;
};
