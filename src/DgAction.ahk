class DgAction extends DgObject ; action definition
{
    __New()
    {
        this.enabled        := true
        this.groupName      := "Default"
        this.sound          := ""
        this.handler        := ""
        this.context        := ""
        this.modifiers      := ""
        this.description    := ""
        this.digiHotKeys    := []
    }
}
;==============================================================================
;==============================================================================
class DgActionGroup extends DgObject
{
    __New( name_ := "Default")
    {
        this.name       := name_
        this.actions    := []
        this.enabled    := true
    }
}