package dev.masterhesse.diglearn.ai.provider;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;

@Service
@ConditionalOnProperty(prefix = "diglearn.ai", name = "mode", havingValue = "stub", matchIfMissing = true)
public class StubLlmGateway implements LlmGateway {

    @Override
    public LlmAnswer chat(LlmPrompt prompt, LlmChatOptions options) {
        String content = """
                [Stub AI]
                当前仍处于骨架联调阶段，尚未调用真实大模型。
                
                若看到这条回复，说明以下链路已经通了：
                1. AI Controller
                2. AI Service
                3. Prompt 组装
                4. LlmGateway 抽象
                5. RAG 检索占位
                
                当前请求参数：
                - model: %s
                - thinking: %s
                - thinkingBudget: %s
                
                下一步可以切换到 live 模式来接入真实 DashScope / Spring AI。
                """.formatted(
                options.model(),
                options.thinking(),
                options.thinkingBudget()
        );

        return new LlmAnswer(
                content,
                null,
                true,
                "stub"
        );
    }
}