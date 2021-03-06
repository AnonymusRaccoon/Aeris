import { useNavigate, useSearchParams } from "react-router-dom";
import { sendServiceAuthToken } from "../../utils/utils";
import { useEffect } from "react";

interface ServiceAuthProps {
    service: string
    endpoint: string
    redirect_uri: string
    navigate_to: string
}

export default function ServiceAuth({ service, endpoint, redirect_uri, navigate_to }: ServiceAuthProps) {
    const [searchParams] = useSearchParams();
    const navigate = useNavigate();
    const authCode = searchParams.get("code") as string;

    useEffect(() => {
        sendServiceAuthToken(authCode, "/auth/" + service + endpoint, `${window.location.origin}/${redirect_uri}`).then((ok) => {
            navigate(navigate_to);
        })
    }, []);

    return <div />;
}