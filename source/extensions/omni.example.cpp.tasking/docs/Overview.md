# Overview

An [example C++ extension](http://omniverse-docs.s3-website-us-east-1.amazonaws.com/kit-extension-template-cpp/106.0.1/index.html) that can be used as a reference/template for creating new extensions.

Demonstrates how to create a C++ object that uses the carb tasking system for async processing.

See also: [https://docs.omniverse.nvidia.com/kit/docs/carbonite/latest/docs/tasking/index.html](https://docs.omniverse.nvidia.com/kit/docs/carbonite/latest/docs/tasking/index.html)


# C++ Usage Examples


## Spawning Tasks


```
class ExampleTaskingExtension : public omni::ext::IExt
{
public:
    void onStartup(const char* extId) override
    {
        // Get the tasking interface from the Carbonite Framework.
        carb::tasking::ITasking* tasking = carb::getCachedInterface<carb::tasking::ITasking>();

        // Add a task defined by a standalone function.
        tasking->addTask(carb::tasking::Priority::eDefault, {}, &exampleStandaloneFunctionTask, this);

        // Add a task defined by a member function.
        tasking->addTask(carb::tasking::Priority::eDefault, {}, &ExampleTaskingExtension::exampleMemberFunctionTask, this);

        // Add a task defined by a lambda function.
        tasking->addTask(carb::tasking::Priority::eDefault, {}, [this] {
            // Artifical wait to ensure this task finishes first.
            carb::getCachedInterface<carb::tasking::ITasking>()->sleep_for(std::chrono::milliseconds(1000));
            printHelloFromTask("exampleLambdaFunctionTask");
        });
    }

    void onShutdown() override
    {
        std::lock_guard<carb::tasking::MutexWrapper> lock(m_helloFromTaskCountMutex);
        m_helloFromTaskCount = 0;
    }

    void exampleMemberFunctionTask()
    {
        // Artifical wait to ensure this task finishes second.
        carb::getCachedInterface<carb::tasking::ITasking>()->sleep_for(std::chrono::milliseconds(2000));
        printHelloFromTask("exampleMemberFunctionTask");
    }

    void printHelloFromTask(const char* taskName)
    {
        std::lock_guard<carb::tasking::MutexWrapper> lock(m_helloFromTaskCountMutex);
        ++m_helloFromTaskCount;
        printf("Hello from task: %s\n"
               "%d tasks have said hello since extension startup.\n\n",
               taskName, m_helloFromTaskCount);
    }

private:
    // We must use a fiber aware mutex: https://docs.omniverse.nvidia.com/kit/docs/carbonite/latest/docs/tasking/TaskingBestPractices.html#mutexes
    carb::tasking::MutexWrapper m_helloFromTaskCountMutex;
    int m_helloFromTaskCount = 0;
};

void exampleStandaloneFunctionTask(ExampleTaskingExtension* exampleTaskingExtension)
{
    // Artifical wait to ensure this task finishes last.
    carb::getCachedInterface<carb::tasking::ITasking>()->sleep_for(std::chrono::milliseconds(3000));
    exampleTaskingExtension->printHelloFromTask("exampleStandaloneFunctionTask");
}
```

