#include "elasticlib.h"
#include <iostream>
#include <networktables/NetworkTableInstance.h>

nt::StringTopic Elastic::topic = nt::NetworkTableInstance::GetDefault().GetStringTopic("/Elastic/RobotNotifications");
nt::StringPublisher Elastic::publisher = Elastic::topic.Publish(nt::PubSubOption::SendAll(true), nt::PubSubOption::KeepDuplicates(true));

Elastic::ElasticNotification::ElasticNotification(NotificationLevel level, const std::string &title, const std::string &description)
    : level(level), title(title), description(description) {}

void Elastic::ElasticNotification::SetLevel(NotificationLevel level)
{
  this->level = level;
}

Elastic::ElasticNotification::NotificationLevel Elastic::ElasticNotification::GetLevel() const
{
  return level;
}

void Elastic::ElasticNotification::SetTitle(const std::string &title)
{
  this->title = title;
}

std::string Elastic::ElasticNotification::GetTitle() const
{
  return title;
}

void Elastic::ElasticNotification::SetDescription(const std::string &description)
{
  this->description = description;
}

std::string Elastic::ElasticNotification::GetDescription() const
{
  return description;
}

std::string Elastic::ElasticNotification::ToJson() const
{
  wpi::json jsonData;
  jsonData["level"] = NotificationLevelToString(level);
  jsonData["title"] = title;
  jsonData["description"] = description;
  return jsonData.dump();
}

std::string Elastic::ElasticNotification::NotificationLevelToString(NotificationLevel level)
{
  switch (level)
  {
  case NotificationLevel::INFO:
    return "INFO";
  case NotificationLevel::WARNING:
    return "WARNING";
  case NotificationLevel::ERROR:
    return "ERROR";
  default:
    return "UNKNOWN";
  }
}

void Elastic::SendAlert(const ElasticNotification &alert)
{
  try
  {
    std::string jsonString = alert.ToJson();
    publisher.Set(jsonString);
  }
  catch (const std::exception &e)
  {
    std::cerr << "Error processing JSON: " << e.what() << std::endl;
  }
}
