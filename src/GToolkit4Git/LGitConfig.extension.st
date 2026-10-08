Extension { #name : #LGitConfig }

{ #category : #'*GToolkit4Git' }
LGitConfig class >> config_free: aHandle [
    ^ self
        ffiCallSafely: #(void git_config_free(void *aHandle))
        options: #()
]

{ #category : #'*GToolkit4Git' }
LGitConfig class >> freeFunctionSelector [
    ^ #config_free:
]
