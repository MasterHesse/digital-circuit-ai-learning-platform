package dev.masterhesse.diglearn.sim.importing;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

/**
 * 这里用 class + setter 方式，避免你还需要额外在主类加 @EnableConfigurationProperties。
 */
@Component
@ConfigurationProperties(prefix = "levels.import")
public class LevelsImportProperties {

    /**
     * 是否启用启动导入
     */
    private boolean enabled = true;

    /**
     * 关卡 JSON 目录（相对路径基于工作目录）
     */
    private String dir = "../levels";

    /**
     * true：DB 中存在但目录里不存在的关卡会被删除（谨慎）
     */
    private boolean deleteMissing = false;

    public boolean isEnabled() {
        return enabled;
    }

    public void setEnabled(boolean enabled) {
        this.enabled = enabled;
    }

    public String getDir() {
        return dir;
    }

    public void setDir(String dir) {
        this.dir = dir;
    }

    public boolean isDeleteMissing() {
        return deleteMissing;
    }

    public void setDeleteMissing(boolean deleteMissing) {
        this.deleteMissing = deleteMissing;
    }
}