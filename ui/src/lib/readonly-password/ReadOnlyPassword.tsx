'use client';
import { Button } from '@asphalt-react/button';
import { EyeOpen, EyeOff } from '@asphalt-react/iconpack';
import { useState } from 'react';
import { Input, InputWrapper, InputAddOn } from "@asphalt-react/textfield";

interface ReadOnlyPasswordProps {
    initialValue: string; // Prop to receive initial password value
}

const ReadOnlyPassword: React.FC<ReadOnlyPasswordProps> = ({ initialValue }) => {
    const [isPasswordHidden, setIsPasswordHidden] = useState(true);

    return (
        <InputWrapper disabled>
            <Input
                type={isPasswordHidden ? "password" : "text"}
                value={initialValue}
                enclosed={false}
                disabled
                bezel={false}
            />
            <InputAddOn>
                <Button 
                    system 
                    compact 
                    nude 
                    icon 
                    onClick={() => setIsPasswordHidden(prev => !prev)}
                >
                    {isPasswordHidden ? <EyeOff /> : <EyeOpen />}
                </Button>
            </InputAddOn>
        </InputWrapper>
    );
};

export default ReadOnlyPassword;
