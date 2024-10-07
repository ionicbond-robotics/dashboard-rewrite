#pragma once

#include <string>
#include <iostream>
#include <networktables/NetworkTableInstance.h>
#include <networktables/StringPublisher.h>
#include <networktables/StringTopic.h>
#include <wpi/json.h>

class Elastic {
public:
    struct ElasticNotification {
        enum class NotificationLevel {
            INFO, WARNING, ERROR
        };

        ElasticNotification(NotificationLevel level, const std::string &title, const std::string &description) 
            : level(level), title(title), description(description) {}

        void SetLevel(NotificationLevel level) { this->level = level; }

        NotificationLevel GetLevel() const { return level; }

        void SetTitle(const std::string &title) { this->title = title; }

        std::string GetTitle() const { return title; }

        void SetDescription(const std::string &description) { this->description = description; }

        std::string GetDescription() const { return description; }

        std::string ToJson() const {
            wpi::json jsonData;
            jsonData["level"] = NotificationLevelToString(level);
            jsonData["title"] = title;
            jsonData["description"] = description;
            return jsonData.dump();
        }

        static std::string NotificationLevelToString(NotificationLevel level) {
            switch (level) {
            case NotificationLevel::INFO: return "INFO";
            case NotificationLevel::WARNING: return "WARNING";
            case NotificationLevel::ERROR: return "ERROR";
            default: return "UNKNOWN";
            }
        }

    private:
        NotificationLevel level;
        std::string title;
        std::string description;
    };

    static void SendAlert(const ElasticNotification &alert) {
        try {
            std::string jsonString = alert.ToJson();
            publisher.Set(jsonString);
        } catch (const std::exception &e) {
            std::cerr << "Error processing JSON: " << e.what() << std::endl;
        }
    }

private:
    static nt::StringTopic topic;
    static nt::StringPublisher publisher;
};

nt::StringTopic Elastic::topic = nt::NetworkTableInstance::GetDefault().GetStringTopic("/Elastic/RobotNotifications");
nt::StringPublisher Elastic::publisher = Elastic::topic.Publish(nt::PubSubOption::SendAll(true), nt::PubSubOption::KeepDuplicates(true));
